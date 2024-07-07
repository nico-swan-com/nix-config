{ lib, configVars, ... }: {
  i18n.defaultLocale = lib.mkDefault configVars.locale;
  time.timeZone = lib.mkDefault configVars.timezone;
}
