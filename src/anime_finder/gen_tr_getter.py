# %%
import humps
import json
import sys

with open('assets/translation.json', encoding='utf-8') as json_file:
    with open('lib/service/translation.g.dart', 'w', encoding='utf-8') as dart_file:
        dart_file.write("import 'package:get/get.dart';\n\n")
        translations = json.load(json_file)['translations']
        for key in translations.keys():
            dart_file.write(f'String get {humps.camelize("tr_"+key)} => "{key}".tr;\n')
# %%
