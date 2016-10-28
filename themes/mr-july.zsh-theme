#!/usr/bin/env zsh
########## COLOR ###########
for COLOR in CYAN WHITE YELLOW MAGENTA BLACK BLUE RED DEFAULT GREEN GREY; do
  eval PR_$COLOR='%{$fg[${(L)COLOR}]%}'
  eval PR_BRIGHT_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
done
PR_RESET="%{$reset_color%}"
ZSH_PROMPT_BASE_COLOR="${PR_RESET}"
VCS_DIRTY_COLOR="${PR_RESET}${PR_YELLOW}"
VCS_CLEAN_COLOR="${PR_RESET}${PR_GREEN}"
VCS_SUFIX_COLOR="${PR_RESET}${PR_RED}›${PR_RESET}"
# ########## COLOR ###########
# ########## SVN ###########
ZSH_THEME_SVN_PROMPT_PREFIX="${PR_RESET}${PR_RED}‹svn:"
ZSH_THEME_SVN_PROMPT_SUFFIX="${VCS_SUFIX_COLOR}"
ZSH_THEME_SVN_PROMPT_DIRTY="${VCS_DIRTY_COLOR}✘${PR_RESET}"
ZSH_THEME_SVN_PROMPT_CLEAN="${VCS_CLEAN_COLOR}✔${PR_RESET}"
ZSH_THEME_SVN_PROMPT_ADDITIONS="${PR_RESET}${PR_YELLOW}✚${PR_RESET}"
ZSH_THEME_SVN_PROMPT_DELETIONS="${PR_RESET}${PR_YELLOW}✖${PR_RESET}"
ZSH_THEME_SVN_PROMPT_MODIFICATIONS="${PR_RESET}${PR_YELLOW}✹${PR_RESET}"
ZSH_THEME_SVN_PROMPT_REPLACEMENTS="${PR_RESET}${PR_YELLOW}➜${PR_RESET}"
ZSH_THEME_SVN_PROMPT_UNTRACKED="${PR_RESET}${PR_YELLOW}✭${PR_RESET}"
ZSH_THEME_BRANCH_NAME_COLOR=${PR_RESET}${PR_BRIGHT_YELLOW}
# ########## SVN ###########
# ########## GIT ###########
ZSH_THEME_GIT_PROMPT_PREFIX="${PR_RESET}${PR_RED}‹git:"
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="${VCS_DIRTY_COLOR} ✘${VCS_SUFIX_COLOR}"
ZSH_THEME_GIT_PROMPT_CLEAN="${VCS_CLEAN_COLOR} ✔${VCS_SUFIX_COLOR}"
ZSH_THEME_GIT_PROMPT_ADDED="${PR_RESET}${PR_YELLOW} ✚${PR_RESET}"
ZSH_THEME_GIT_PROMPT_MODIFIED="${PR_RESET}${PR_YELLOW} ✹${PR_RESET}"
ZSH_THEME_GIT_PROMPT_DELETED="${PR_RESET}${PR_YELLOW} ✖${PR_RESET}"
ZSH_THEME_GIT_PROMPT_RENAMED="${PR_RESET}${PR_YELLOW} ➜${PR_RESET}"
ZSH_THEME_GIT_PROMPT_UNMERGED="${PR_RESET}${PR_YELLOW} ═${PR_RESET}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="${PR_RESET}${PR_YELLOW} ✭${PR_RESET}"
# ########## GIT ###########
function precmd {
  # set a simple variable to show when in screen
  if [[ -n "${WINDOW}" ]]; then
    SCREEN=""
  fi
}


# get the length of specified prompt part
get_prompt_part_length () {
  local pr_part="$1"
  local zero='%([BSUbfksu]|([FBK]|){*})'
  echo -n "${#${(S%%)pr_part//$~zero/}}"
}


# Context: user@directory or just directory
prompt_context () {
  local contextMaxLen=${1}
  local pr_user="$USER@%m"
  local pr_user_length=$(get_prompt_part_length "$pr_user")
  local pathMaxLength=$(( $contextMaxLen - $pr_user_length - 1 ))
  local pr_path;

  for pr_path in "%~%<<" "$(shrink_path -t -l)" "%${pathMaxLength}<...<%~%<<"; do
    local pr_path_length=$(get_prompt_part_length "$pr_path")

    if [[ $pr_path_length -lt $pathMaxLength ]]; then
      break
    fi
  done

  local padding=${(r:$(( $pathMaxLength - $pr_path_length )):: :)""}
  local pr_left="${PR_RESET}${PR_BRIGHT_GREEN}${pr_user}${PR_RESET} ${PR_BRIGHT_BLUE}${pr_path}${PR_RESET}${padding}"

  #echo -n $pr_path_length
  echo -n "${pr_left}"
}

set_prompt () {
  # required for the prompt
  setopt prompt_subst
  autoload zsh/terminfo
  local arrowStart='┌─'
  local   arrowEnd='└─▶'
  local timeStr='%{$fg[yellow]%}%D{[%X]}'
  local vcsInfo='${PR_RESET}$(git_prompt_info)$(svn_prompt_info)'
  local str="$arrowStart $vcsInfo $timeStr "
  local contextMaxLength='$(( $COLUMNS - $(get_prompt_part_length "'$str'") ))'

  # ######### PROMPT #########
  PROMPT="$arrowStart"'$(prompt_context '$contextMaxLength") $vcsInfo $timeStr ${PR_RESET}
$arrowEnd "
  #RPROMPT="$vcsInfo"
  # Matching continuation prompt
  PROMPT2="  $arrowEnd"'${PR_RESET}%_${PR_RESET} '
  # ######### PROMPT #########
}

set_prompt
