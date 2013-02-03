=== Zad�n�
Pretty-printer
   zdrojov� text v Pascalu prevede do HTML s t�m, �e
   - zv�razn� kl�cov� slova
   - rozdel� do r�dek
   - odsad� vnoren� pr�kazy

=== Zvolen� algoritmus 
Line�rn� proj�t� zadan�ho zdrojov�ho souboru (na jeden pruchod), bez jak�hokoli typu vracen�.

=== Diskuse v�beru algoritmu
Vet�ina online syntax-highlihter-u k zv�raznen� pou��v� regul�rn� v�razy, 
co� mu�e b�t na velk�m vstupu hodne pomal�.
Chtel jsem zkusit, jak program bude vypadat s line�rn� casovou slo�itost�.
Byla to tak trochu v�zva.

=== Program
Program pracuje tak, �e dostane dva soubory jako parametr - �ablonu (nepovinne) a zrojov� soubor.
�ablonu tiskne, dokud v n� nenaraz� na nejakou promennou - promenn� {$output} zacne
vypisov�n� zdrojov�ho souboru.
Pro uchov�n� stavu, jsem m�sto booleanovsk�ch promenn�ch zavedl masky (modifik�tory),
proto�e jednodu�eji kontroluji nekolik stavu zar�z.

=== Alternativn� programov� re�en�
Nejprve jsem to chtel udelat na dva pruchody:
- v prvn�m pruchodu bych si ulo�il n�zvy promenn�ch, funkc�, ...
- ve druh�m pruchodu bych potom promenn� se stejn�m n�zvem prov�zal
a javasriptem by �ly zv�raznit v�echny v�skyty.
Nicm�ne i s touto my�lenkou by to �lo udelat na jeden pruchod,
ale trochu by se to zkomplikovalo.

=== Reprezentace vstupn�ch dat a jejich pr�prava
Vstupn� soubor: zdrojov� k�d: soubor typu PAS, kter� lze prelo�it (neobsahuje syntax chyby)
Vstupn� soubor (nepovinn�): �ablona [template.html]: obsahuje predpripraven� styly
  a promennou {$output}, kde se vyp�e zdrojov� k�d
Oba soubory by mely b�t v k�dov�n� ANSI.

=== Reprezentace v�stupn�ch dat a jejich interpretace
V�stupn� soubor: HTML dokument se zv�raznen�m zdrojov�m k�dem
V�stupn� soubor (nepovinn�): Odsazen� cist� zdrojov� k�d (bez HTML znacek)

=== Co nebylo dodel�no
- Odsazen� jednor�dkov�ch pr�kazu (bez uvozen� blokem begin-end).
- Zv�raznen� promenn�ch, funkc�, ... se stejn�m jm�nem pri najet� my�� (javascriptem)

=== Prekladac
- Lze prelo�it jak ve Free Pascalu 2.6.0, tak i v Borland Pascalu
- Borland um� otevr�t pouze souory s n�zvem d�lky men��m ne� 8+3 => je treba prejmenovat