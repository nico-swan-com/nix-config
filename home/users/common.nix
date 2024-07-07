{ configVars, ... }:
{
  home.sessionVariables = {
    EDITOR = configVars.editor;
  };
}
