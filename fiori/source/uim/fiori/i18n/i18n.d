module uim.fiori.i18n.controller;

import uim.fiori;

@safe:
void I18nHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    res.writeBody("I18nHandler response");
}