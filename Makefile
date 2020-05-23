.PHONY: all help run

# target: all - Runs both django and celery if used with -j
all: run

# target: help - Display callable targets.
help:
	@egrep "^# target:" [Mm]akefile

# target: run - restow all configs
run:
	stow --restow --verbose --target=${HOME} fish vscode