# ----------------------------------------------------------------------------------
# Python Related Bash Scripts
# Jeffrey D. Shaffer
# Updated -- 2025-12-26
#
# ----------------------------------------------------------------------------------


env-list(){
    echo "Currently Available Environments:"
    ls ~/.venvs
    }


env-open(){
    if [[ -z "$1" ]]; then
        echo "Environment name missing..."
        echo "Currently Available Environments:"
        ls ~/.venvs
        return 0
    fi
    source ~/.venvs/"$1"/bin/activate
    }


alias env-close="deactivate"


env-make(){
    if [[ -z "$1" ]]; then
        echo "Environment name missing..."
        return 0
    fi
    python3 -m venv ~/.venvs/"$1"
    echo "Environment Created:  $1"
    }

env-delete(){
    if [[ -z "$1" ]]; then
        echo "Environment name missing. No changes made."
        echo "Currently Available Environments:"
        ls ~/.venvs
        return 0
    fi
    rm -r ~/.venvs/"$1"
    echo "Environment deleted:  $1"
    }
