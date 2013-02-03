# Pretty Printer v1.0 #
Zápočtový program pro první semestr MFF-UK, obecná informatika.

## Zadání
Pretty-printer
   zdrojový text v Pascalu převede do HTML s tím, že
   - zvýrazní klíčová slova
   - rozdělí do řádek
   - odsadí vnořené příkazy

## Zvolený algoritmus 
Lineární projítí zadaného zdrojového souboru (na jeden průchod), bez jakéhokoli typu vracení.

## Diskuse výběru algoritmu
Vetšina online syntax-highlihter-u k zvýraznení používá regulární výrazy, 
což muže být na velkém vstupu hodně pomalé.
Chtěl jsem zkusit, jak program bude vypadat s lineární časovou složitostí.
Byla to tak trochu výzva.

## Program 
Program pracuje tak, že dostane dva soubory jako parametr - šablonu (nepovinně) a zdrojový soubor.
Šablonu tiskne, dokud v ní nenarazí na nějakou proměnnou - proměnná {$output} začne
vypisování zdrojového souboru.
Pro uchování stavu, jsem místo booleanovských proměnných zavedl masky (modifikátory),
protože jednodušeji kontroluji několik stavu najednou.

## Alternativní programová rešení 
Nejprve jsem to chtel udělat na dva průchody:
- v prvním pruchodu bych si uložil názvy proměnných, funkcí, ...
- ve druhém pruchodu bych potom proměnné se stejným názvem provázal  
a javasriptem by šly zvýraznit všechny výskyty.   
Nicméne i s touto myšlenkou by to šlo udelat na jeden průchod,  
ale trochu by se to zkomplikovalo.

## Reprezentace vstupních dat a jejich příprava 
Vstupní soubor: zdrojový kód: soubor typu PAS, který lze přeložit (neobsahuje syntax chyby)  
Vstupní soubor (nepovinný): šablona [template.html]: obsahuje předpripravené styly  
  a proměnnou {$output}, kde se vypíše zdrojový kód  
Oba soubory by mely být v kódování ANSI.

## Reprezentace výstupních dat a jejich interpretace
Výstupní soubor: HTML dokument se zvýrazněným zdrojovým kódem   
Výstupní soubor (nepovinný): Odsazený čistý zdrojový kód (bez HTML značek)

## Co nebylo doděláno
- Odsazení jednořádkových příkazů (bez uvození blokem begin-end).
- Zvýraznění proměnných, funkcí, ... se stejným jménem při najetí myší (javascriptem)
                                                                                                            
## Jak přeložit
- Lze přeložit jak ve Free Pascalu 2.6.0, tak i v Borland Pascalu
- Borland umí otevřít pouze souory s názvem délky menším než 8+3 => je třeba přejmenovat šablony