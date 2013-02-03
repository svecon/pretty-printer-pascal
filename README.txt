=== Zadání
Pretty-printer
   zdrojovı text v Pascalu prevede do HTML s tím, e
   - zvırazní klícová slova
   - rozdelí do rádek
   - odsadí vnorené príkazy

=== Zvolenı algoritmus 
Lineární projítí zadaného zdrojového souboru (na jeden pruchod), bez jakéhokoli typu vracení.

=== Diskuse vıberu algoritmu
Vetšina online syntax-highlihter-u k zvıraznení pouívá regulární vırazy, 
co mue bıt na velkém vstupu hodne pomalé.
Chtel jsem zkusit, jak program bude vypadat s lineární casovou sloitostí.
Byla to tak trochu vızva.

=== Program
Program pracuje tak, e dostane dva soubory jako parametr - šablonu (nepovinne) a zrojovı soubor.
Šablonu tiskne, dokud v ní nenarazí na nejakou promennou - promenná {$output} zacne
vypisování zdrojového souboru.
Pro uchování stavu, jsem místo booleanovskıch promennıch zavedl masky (modifikátory),
protoe jednodušeji kontroluji nekolik stavu zaráz.

=== Alternativní programová rešení
Nejprve jsem to chtel udelat na dva pruchody:
- v prvním pruchodu bych si uloil názvy promennıch, funkcí, ...
- ve druhém pruchodu bych potom promenné se stejnım názvem provázal
a javasriptem by šly zvıraznit všechny vıskyty.
Nicméne i s touto myšlenkou by to šlo udelat na jeden pruchod,
ale trochu by se to zkomplikovalo.

=== Reprezentace vstupních dat a jejich príprava
Vstupní soubor: zdrojovı kód: soubor typu PAS, kterı lze preloit (neobsahuje syntax chyby)
Vstupní soubor (nepovinnı): šablona [template.html]: obsahuje predpripravené styly
  a promennou {$output}, kde se vypíše zdrojovı kód
Oba soubory by mely bıt v kódování ANSI.

=== Reprezentace vıstupních dat a jejich interpretace
Vıstupní soubor: HTML dokument se zvıraznenım zdrojovım kódem
Vıstupní soubor (nepovinnı): Odsazenı cistı zdrojovı kód (bez HTML znacek)

=== Co nebylo dodeláno
- Odsazení jednorádkovıch príkazu (bez uvození blokem begin-end).
- Zvıraznení promennıch, funkcí, ... se stejnım jménem pri najetí myší (javascriptem)

=== Prekladac
- Lze preloit jak ve Free Pascalu 2.6.0, tak i v Borland Pascalu
- Borland umí otevrít pouze souory s názvem délky menším ne 8+3 => je treba prejmenovat