#!/usr/bin/env python3
"""Check terminal helpers in temporary directories without changing user repositories."""
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
ENV = dict(os.environ, GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
           GIT_AUTHOR_NAME='Terminal tests', GIT_AUTHOR_EMAIL='terminal@example.invalid',
           GIT_COMMITTER_NAME='Terminal tests', GIT_COMMITTER_EMAIL='terminal@example.invalid',
           FZF_DEFAULT_OPTS='', FZF_DEFAULT_OPTS_FILE='')
checks = 0


def check(condition, name):
    global checks
    if not condition:
        raise AssertionError(name)
    checks += 1
    print('PASS', name)


def shell(code, cwd, stdin=None, **env):
    setup = 'source "$1/functions/dev.zsh"; source "$1/functions/git.zsh"; source "$1/functions/navigation.zsh"; '
    return subprocess.run(['/bin/zsh', '-f', '-c', setup + code, 'test', str(ROOT)],
                          cwd=cwd, input=stdin, text=True, capture_output=True, env=ENV | env)


def git(cwd, *args):
    return subprocess.run(['git', *args], cwd=cwd, env=ENV, text=True,
                          capture_output=True, check=True).stdout


with tempfile.TemporaryDirectory(prefix='terminal-regression-') as tmp:
    work = Path(tmp)
    result = shell('json', work, '{"ok":true}')
    check(result.returncode == 0 and json.loads(result.stdout) == {'ok': True}, 'JSON stdin with installed bat')
    result = shell('PATH=/usr/bin:/bin; rehash; json', work, '{"ok":true}')
    check(result.returncode == 0 and json.loads(result.stdout) == {'ok': True}, 'JSON stdin without bat')
    check(shell('json', work, '{invalid').returncode != 0, 'invalid JSON retains failure')
    result = shell('port invalid', work)
    check(result.returncode != 0 and 'usage:' in result.stderr, 'port rejects invalid input')
    result = shell('port', work)
    check(result.returncode in (0, 1) and 'command not found' not in result.stderr,
          'port runs macOS lsof without unavailable ss')
    empty = work / 'empty'
    empty.mkdir()
    check(shell('size', empty).returncode == 0, 'size handles an empty directory')
    for name in ['one space', 'second', '.hidden']:
        folder = work / name
        folder.mkdir()
        (folder / 'data').write_text('hello')
    result = shell('size "one space" second', work)
    check(result.returncode == 0 and 'one space/data' in result.stdout and 'second/data' in result.stdout,
          'size preserves multiple directory arguments')
    check('.hidden' in shell('size', work).stdout, 'size includes hidden entries')
    check(shell('up zero', work).returncode != 0, 'up rejects invalid levels')
    result = shell('mkcd "new folder" >/dev/null && print -r -- "$PWD"', work)
    check(result.returncode == 0 and Path(result.stdout.strip()).resolve() == (work / 'new folder').resolve(), 'mkcd preserves spaces')
    repo = work / 'repo%F{red}'
    repo.mkdir()
    git(repo, 'init', '-q', '-b', 'main')
    (repo / 'tracked').write_text('initial\n')
    git(repo, 'add', '--all')
    git(repo, 'commit', '-qm', 'initial')
    git(repo, 'branch', 'feature')
    result = shell('FZF_DEFAULT_OPTS="--filter=feature"; gsw', repo)
    check(result.returncode == 0 and git(repo, 'branch', '--show-current').strip() == 'feature',
          'branch selector switches a local branch')
    git(repo, 'remote', 'add', 'upstream', str(repo))
    git(repo, 'update-ref', 'refs/remotes/upstream/remote-feature', 'HEAD')
    result = shell('FZF_DEFAULT_OPTS="--filter=upstream/remote-feature"; gsw', repo)
    check(result.returncode == 0 and git(repo, 'branch', '--show-current').strip() == 'remote-feature',
          'branch selector tracks a non-origin remote')
    for name in ['space name', "quote'name", '-leading', 'line\nbreak']:
        (repo / name).write_text('new\n')
    result = shell('FZF_DEFAULT_OPTS="--filter="; gadd', repo)
    if result.returncode: print('gadd diagnostics:', repr(result.stdout), repr(result.stderr))
    staged = git(repo, 'diff', '--cached', '--name-only', '-z').split('\0')
    check(result.returncode == 0 and all(n in staged for n in ['space name', "quote'name", '-leading', 'line\nbreak']),
          'staging preserves spaces, quotes, leading hyphens and newlines')
    git(repo, 'commit', '-qm', 'files')
    (repo / 'tracked').unlink()
    result = shell('FZF_DEFAULT_OPTS="--filter=tracked"; gadd', repo)
    check(result.returncode == 0 and 'D\ttracked' in git(repo, 'diff', '--cached', '--name-status'),
          'staging includes deleted files')
    git(repo, 'reset', '--hard', '-q', 'HEAD')
    result = shell('FZF_DEFAULT_OPTS="--filter=NOT-A-FILE"; gadd', repo)
    check(result.returncode != 0 and not git(repo, 'diff', '--cached', '--name-only'), 'cancelled selection stages nothing')
    (repo / 'tracked').write_text('changed\n')
    git(repo, 'add', '--all')
    git(repo, 'commit', '-qm', 'fix: mentions wip: in ordinary subject')
    before = git(repo, 'rev-parse', 'HEAD')
    result = shell('gunwip', repo)
    check(result.returncode != 0 and git(repo, 'rev-parse', 'HEAD') == before, 'gunwip rejects an ordinary commit')
    git(repo, 'commit', '--allow-empty', '-qm', 'wip: test')
    result = shell('gunwip', repo)
    check(result.returncode == 0 and git(repo, 'rev-parse', 'HEAD') == before, 'gunwip undoes a WIP commit')
    git(repo, 'switch', '-qc', 'ahead-of-time')
    (repo / 'behind-file').write_text('new')
    result = shell('source "$1/prompt"; _prompt_precmd; print -r -- "$_P_GIT"; print -P -- "$_P_DIR"', repo)
    check('\uf062' not in result.stdout and '\uf063' not in result.stdout, 'prompt ignores ahead/behind in branch and filenames')
    check('repo%F{red}' in result.stdout, 'prompt renders percent characters literally')
    git(repo, 'switch', '-qc', 'literal%F{red}')
    result = shell('source "$1/prompt"; _prompt_precmd; print -P -- "$_P_GIT"', repo)
    check('literal%F{red}' in result.stdout and 'literal%%' not in result.stdout, 'prompt renders branch percent characters literally')
    result = shell('source "$1/prompt"; SECONDS=3; _cmd_start=0; _prompt_precmd; print -r -- "$_P_EXECTIME"', empty)
    check('3s' in result.stdout, 'timer includes commands started during second zero')
    syntax = subprocess.run(['/bin/zsh', '-n', str(ROOT / '.zshrc')], capture_output=True)
    check(syntax.returncode == 0, 'interactive configuration syntax')
    result = shell('source "$1/functions/conda.zsh"; (( ! $+functions[__conda_activate] ))', work)
    check(result.returncode == 0, 'Conda initialisation is deferred')
    result = shell('source "$1/functions/conda.zsh"; conda activate base && '
                   '[[ $CONDA_PREFIX == "$HOME/miniconda3" ]] && '
                   'conda deactivate && [[ -z $CONDA_PREFIX ]]', work)
    check(result.returncode == 0, 'first-use Conda activation and deactivation')
    result = shell('source "$1/functions/conda.zsh"; conda --version >/dev/null || exit; '
                   'original=$functions[conda]; source "$1/functions/conda.zsh"; '
                   '[[ $functions[conda] == "$original" ]]', work)
    check(result.returncode == 0, 're-sourcing preserves initialised Conda')
    fake_home = work / 'missing-conda'
    fake_home.mkdir()
    result = shell('source "$1/functions/conda.zsh"; conda --version', work, HOME=str(fake_home))
    check(result.returncode == 127 and 'not found' in result.stderr, 'missing Conda installation reports a useful failure')
    profile = fake_home / 'miniconda3/etc/profile.d/conda.sh'
    profile.parent.mkdir(parents=True)
    profile.write_text('return 78\n')
    result = shell('source "$1/functions/conda.zsh"; conda --version', work, HOME=str(fake_home))
    check(result.returncode == 78, 'Conda initialisation failure retains its exit status')
print(f'{checks} checks passed')
