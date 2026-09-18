module uim.fiori.i18n.de;

import uim.fiori;

@safe:
void DeI18nHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    res.writeBody("DeI18nHandler response");
}