
# Some important variables
   export EDITOR=vim                           
   export PAGER=less                           
   export LESSHISTFILE="/dev/null"             
   export LESS="-R"                            
   export LANG="en_US.UTF-8"                   
   
# Misc
   declare -U path                             
   eval $(dircolors $ZSH_CONF/dircolors)       
   umask 002                                   
   setopt NO_BEEP                              
   setopt AUTO_CD                              
   setopt MULTI_OS                             
   unsetopt NO_HUP                             
   setopt INTERACTIVE_COMMENTS                 
   setopt RC_EXPAND_PARAM                      
   unsetopt FLOW_CONTROL                       
   setopt LONG_LIST_JOBS                       
   setopt vi                                   


   alias history='fc -fl 1'
   SAVEHIST=10000                              
   HISTSIZE=10000                              
   setopt EXTENDED_HISTORY                     
   setopt APPEND_HISTORY                       
   setopt HIST_FIND_NO_DUPS                    
   setopt HIST_EXPIRE_DUPS_FIRST               
   setopt HIST_IGNORE_SPACE                    
   setopt HIST_VERIFY                          
   setopt SHARE_HISTORY                        
   setopt HIST_IGNORE_DUPS                     
   setopt INC_APPEND_HISTORY                   
   setopt HIST_REDUCE_BLANKS                   

# ZSH Auto Completion
   # Figure out the short hostname
   if [[ "$OSTYPE" = darwin* ]]; then          
      # OS X's $HOST changes with dhcp, etc., so use ComputerName if possible.
      SHORT_HOST=$(scutil --get ComputerName 2>/dev/null) || SHORT_HOST=${HOST/.*/}
   else
      SHORT_HOST=${HOST/.*/}
   fi

   #the auto complete dump is a cache file where ZSH stores its auto complete data, for faster load times
   local ZSH_COMPDUMP="$ZSH_CACHE/acdump-${SHORT_HOST}-${ZSH_VERSION}"  

   autoload -Uz compinit
   compinit -i -d "${ZSH_COMPDUMP}"                        
   zstyle ':completion:*' menu select                      
   zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'     
   setopt COMPLETE_IN_WORD                                 
   setopt ALWAYS_TO_END                                    
   setopt MENU_COMPLETE                                    
   setopt COMPLETE_ALIASES                                 
   setopt LIST_ROWS_FIRST                                  

# Globbing
   setopt NO_CASE_GLOB                         
   setopt EXTENDED_GLOB                        
   
   setopt NUMERIC_GLOB_SORT                    
   
# Aliases
   alias vi="vim"
   alias -g ...='../..'
   alias -g ....='../../..'
   alias -g .....='../../../..'
   alias -g ......='../../../../..'
   alias -g .......='../../../../../..'
   alias -g ........='../../../../../../..'
   
   alias ls="ls -h --color='auto'"
   alias lsa='ls -A'
   alias ll='ls -l'
   alias la='ls -lA'
   alias lx='ls -lXB'    
   alias lt='ls -ltr'
   alias lk='ls -lSr'
   alias cdl=changeDirectory; function changeDirectory { cd $1 ; la }

   alias md='mkdir -p'
   alias rd='rmdir'

   
   alias psg="ps aux $( [[ -n "$(uname -a | grep CYGWIN )" ]] && echo '-W') | grep -i $1"

# Setup grep to be a bit more nice
  
   grep-flag-available() {
         echo | grep $1 "" >/dev/null 2>&1
   }

   local GREP_OPTIONS=""

