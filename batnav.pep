;batnav

main:    LDA     0x0000,i    
         LDX     0x0000,i    
         STRO    msgacc,d    
lire:    CALL    fctlire     
         CALL    fctverif    
         CALL    tstcart     
more:    CALL    fctcarte    
         STRO    msgfeu,d    
         CALL    restst      
         CALL    missile     
         CALL    restst      
         CALL    parafeu     
         CALL    restst      
tirsuite:CALL    feu         
         CALL    restst      
         CALL    tstvie      
         CALL    fctcarte    
         STRO    msgfin,d    
         CALL    rejouer  
   
;sous-programme pour afficher la carte
fctcarte:STRO    cartetop,d  
         STRO    carte,d     
         RET0   
             
;sous-programmme pour insérer les coordonnées entrées pour les bateaux dans un tableau
fctlire: LDA     0x0000,i    
         LDX     0x0000,i    
         CALL    fctcarte    
         STRO    placebat,d  
looplire:CHARI   choixbat,d  
         LDBYTEA choixbat,d  
         CPA     '\x0a',i    
         BREQ    finlire     
         STBYTEA tabbat,x    
         ADDX    1,i         
         CPX     batlong,d   
         BREQ    finlire     
         BR      looplire    
finlire: CHARO   '\n',i      
         RET0  

;sous-programmme pour verifier si les données dans le tableau des bateaux sont valides                 
fctverif:LDA     0x0000,i    
         LDX     0x0000,i    
grpara:  LDBYTEA tabbat,x    
         CPA     '\x0a',i    
         BREQ    errpara     
         CPA     'p',i       
         BREQ    oripara     
         CPA     'm',i       
         BREQ    oripara     
         CPA     'g',i       
         BREQ    oripara     
         BR      errpara     
oripara: ADDX    1,i         
         LDBYTEA tabbat,x    
         CPA     'h',i       
         BREQ    colpara     
         CPA     'v',i       
         BREQ    colpara     
         BR      errpara     
colpara: ADDX    1,i         
         LDBYTEA tabbat,x    
         CPA     'A',i       
         BRLT    errpara     
         CPA     'R',i       
         BRGT    errpara     
;partie rangee parametre
         ADDX    1,i         
         LDBYTEA tabbat,x    
         CPA     '1',i       
         BRLT    errpara     
         CPA     '9',i       
         BRGT    errpara     
;partie espace ou retour chariot
         ADDX    1,i         
         LDBYTEA tabbat,x    
         CPA     0,i         
         BREQ    finpara     
         CPA     32,i        
         BRNE    errpara     
         ADDX    1,i         
         BR      grpara      
errpara: STRO    errplace,d  
err:     CALL    mapreset    
         CALL    fctrsbat    
         BR      lire        
finpara: RET0  
              
;sous-programme pour reset le tableau des bateaux/input
fctrsbat:LDA     0x0000,i    
         LDX     0x0000,i    
loopbat: LDBYTEA tabbat,x    
         CPA     '\x00',i    
         BRNE    resettab    
         BR      finrsbat    
resettab:LDBYTEA 0,i         
         STBYTEA tabbat,x    
         CHARO   tabbat,x    
         ADDX    1,i         
         BR      loopbat     
finrsbat:RET0    

;sous-programme pour remettre l'accumulateur et l'index à 0                 
restst:  LDA     0x0000,i    
         LDX     0x0000,i    
         RET0 
               
;sous-programmme pour vérifier les paramètres des entrées des bateaux, verifier si il y a une superposition
;et placer les bateaux si les conditions sont respectées
tstcart: LDA     0x0000,i    
         LDX     0x0000,i    
plactst: CALL    parambat    
         LDBYTEA orienbat,d  
         CPA     'h',i       
         BREQ    hor         
         BR      ver         
hor:     LDBYTEA colbat,d    
         CPA     'N',i       
         BRGT    N           
         CPA     'P',i       
         BRGT    P           
         BR      nextbat     
P:       LDBYTEA grandbat,d  
         CPA     'p',i       
         BRNE    horsbat     
         BR      nextbat     
N:       LDBYTEA grandbat,d  
         CPA     'g',i       
         BREQ    horsbat     
         BR      nextbat     
ver:     LDBYTEA grandbat,d  
         CPA     'm',i       
         BREQ    m           
         CPA     'g',i       
         BREQ    g           
         BR      nextbat     
m:       LDBYTEA rangbat,d   
         CPA     '7',i       
         BRGT    horsbat     
         BR      nextbat     
g:       LDBYTEA rangbat,d   
         CPA     '5',i       
         BRGT    horsbat     
         BR      nextbat     
nextbat: ADDX    1,i         
         LDBYTEA tabbat,x    
         CPA     32,i        
         BREQ    next        
         CPA     0,i         
         BREQ    placer      
next:    ADDX    1,i
         ldbytea tabbat,x
         cpa     32,i         
         breq    next         
         BR      plactst     
placer:  LDA     0x0000,i    
         LDX     0x0000,i    
encore:  CALL    parambat
         cpa     0,i 
         breq    more    
         LDBYTEA rangbat,d   
         SUBA    49,i        
         STA     irang,d     
         LDBYTEA colbat,d    
         SUBA    62,i        
         STA     icol,d      
         LDBYTEA grandbat,d  
         CPA     'g',i       
         BREQ    grand       
         CPA     'm',i       
         BREQ    moyen       
         BR      petit       
petit:   LDX     0,i         
         LDA     0,i         
         STA     temp,d      
         LDX     icol,d      
petitv:  CPA     irang,d     
         BREQ    pV          
         ADDX    22,i        
         ADDA    1,i         
         BR      petitv      
pV:      STBYTEX tmpibat,d   
         LDBYTEA 0,i         
         STBYTEA boucl,d     
         BR      repVtstP    
pVV:     CALL    repH        
         BR      nextup      
moyen:   LDBYTEA orienbat,d  
         CPA     'h',i       
         BREQ    mh          
         BR      mv          
mh:      LDX     0,i         
         LDA     0,i         
mhori:   ADDA    22,i        
         ADDX    1,i         
         CPX     irang,d     
         BRNE    mhori       
         STA     temp,d      
         LDX     icol,d      
         ADDX    temp,d      
         STBYTEX tmpibat,d   
         LDBYTEA 0,i         
         STBYTEA boucl,d     
         BR      repHtstM    
mHH:     CALL    repH        
         CALL    repH        
         CALL    repH        
         BR      nextup      
mv:      LDX     0,i         
         LDA     0,i         
         STA     temp,d      
         LDX     icol,d      
mvert:   CPA     irang,d     
         BREQ    mV          
         ADDX    22,i        
         ADDA    1,i         
         BR      mvert       
mV:      STBYTEX tmpibat,d   
         LDBYTEA 0,i         
         STBYTEA boucl,d     
         BR      repVtstM    
mVV:     CALL    repV        
         CALL    repV        
         CALL    repV        
         BR      nextup      
grand:   LDBYTEA orienbat,d  
         CPA     'h',i       
         BREQ    gh          
         BR      gv          
gh:      LDX     0,i         
         LDA     0,i         
grhori:  ADDA    22,i        
         ADDX    1,i         
         CPX     irang,d     
         BRNE    grhori      
         STA     temp,d      
         LDX     icol,d      
         ADDX    temp,d      
         STBYTEX tmpibat,d   
         LDBYTEX tmpibat,d   
         LDBYTEA 0,i         
         STBYTEA boucl,d     
         BR      repHtstG    
gHH:     CALL    repH        
         CALL    repH        
         CALL    repH        
         CALL    repH        
         CALL    repH        
         BR      nextup      
gv:      LDX     0,i         
         LDA     0,i         
         STA     temp,d      
         LDX     icol,d      
grvert:  CPA     irang,d     
         BREQ    grV         
         ADDX    22,i        
         ADDA    1,i         
         BR      grvert      
grV:     STBYTEX tmpibat,d   
         LDBYTEA 0,i         
         STBYTEA boucl,d     
         BR      repVtstG    
gVV:     CALL    repV        
         CALL    repV        
         CALL    repV        
         CALL    repV        
         CALL    repV        
         BR      nextup      
repH:    LDBYTEA carte,x     
         CPA     '~',i       
         BRNE    nextup    
         LDBYTEA '>',i       
         STBYTEA carte,x     
         ADDX    1,i         
         RET0                
repHtstG:LDBYTEA carte,x     
         CPA     '~',i       
         BRNE    nextup    
         ADDX    1,i         
         LDBYTEA 0,i         
         LDBYTEA boucl,d     
         ADDA    1,i         
         STBYTEA boucl,d     
         CPA     5,i         
         BRLT    repHtstG    
         LDBYTEX tmpibat,d   
         LDBYTEA 0,i         
         STBYTEA boucl,d     
         BR      gHH         
repHtstM:LDBYTEA carte,x     
         CPA     '~',i       
         BRNE    nextup    
         ADDX    1,i         
         LDBYTEA 0,i         
         LDBYTEA boucl,d     
         ADDA    1,i         
         STBYTEA boucl,d     
         CPA     3,i         
         BRLT    repHtstM    
         LDBYTEX tmpibat,d   
         LDBYTEA 0,i         
         STBYTEA boucl,d     
         BR      mHH         
repHtstP:LDBYTEA carte,x     
         CPA     '~',i       
         BRNE    nextup    
         ADDX    1,i         
         LDBYTEA 0,i         
         LDBYTEA boucl,d     
         ADDA    1,i         
         STBYTEA boucl,d     
         CPA     1,i         
         BRLT    repHtstP    
         LDBYTEX tmpibat,d   
         LDBYTEA 0,i         
         STBYTEA boucl,d     
         BR      pVV         
repV:    LDBYTEA carte,x     
         CPA     '~',i       
         BRNE    nextup    
         LDBYTEA 'V',i       
         STBYTEA carte,x     
         ADDX    22,i        
         RET0                
repVtstG:LDBYTEA carte,x     
         CPA     '~',i       
         BRNE    nextup    
         ADDX    22,i        
         LDA     0,i         
         LDBYTEA boucl,d     
         ADDA    1,i         
         STBYTEA boucl,d     
         CPA     5,i         
         BRLT    repVtstG    
         LDBYTEX tmpibat,d   
         LDBYTEA 0,i         
         STBYTEA boucl,d     
         BR      gVV         
repVtstM:LDBYTEA carte,x     
         CPA     '~',i       
         BRNE    nextup    
         ADDX    22,i        
         LDBYTEA 0,i         
         LDBYTEA boucl,d     
         ADDA    1,i         
         STBYTEA boucl,d     
         CPA     3,i         
         BRLT    repVtstM    
         LDBYTEX tmpibat,d   
         LDBYTEA 0,i         
         STBYTEA boucl,d     
         BR      mVV         
repVtstP:LDBYTEA carte,x     
         CPA     '~',i       
         BRNE    nextup    
         ADDX    22,i        
         LDBYTEA 0,i         
         LDBYTEA boucl,d     
         ADDA    1,i         
         STBYTEA boucl,d     
         CPA     1,i         
         BRLT    repVtstP    
         LDBYTEX tmpibat,d   
         LDBYTEA 0,i         
         STBYTEA boucl,d     
         BR      pVV         
nextup:  LDX     indexbat,d  
         ADDX    1,i         
         LDBYTEA tabbat,x    
         CPA     0,i         
         BRNE    nouvbat     
         RET0                
nouvbat: ADDX    1,i         
         BR      encore

;sous-programme pour reset la carte après une partie      
mapreset:LDX     0,i         
again:   LDBYTEA carte,x     
         CPA     '*',i       
         BREQ    reset       
         CPA     'o',i       
         BREQ    reset       
         CPA     'v',i       
         BREQ    reset       
         CPA     '>',i       
         BREQ    reset       
         CPA     '\x00',i    
         BREQ    ret         
         ADDX    1,i         
         BR      again       
ret:     RET0                
reset:   LDBYTEA '~',i       
         STBYTEA carte,x     
         ADDX    1,i         
         BR      again 

;sous-programmme pour insérer les coordonnées entrées pour les missiles dans un tableau       
missile: CHARI   choixfeu,d  
         LDBYTEA choixfeu,d  
         CPA     '\x0a',i    
         BREQ    finlire     
         STBYTEA tabfeu,x    
         ADDX    1,i         
         CPX     batlong,d   
         BREQ    finlire     
         BR      missile 

;sous-programmme pour vérifier les paramètres des entrées des missiles      
parafeu: LDBYTEA tabfeu,x    
         CPA     'A',i       
         BRLT    feuerr      
         CPA     'R',i       
         BRGT    feuerr      
         ADDX    1,i         
         LDBYTEA tabfeu,x    
         CPA     '0',i       
         BRLT    feuerr      
         CPA     '9',i       
         BRGT    feuerr      
         ADDX    1,i         
         LDBYTEA tabfeu,x    
         CPA     0,i         
         BREQ    ret         
         CPA     32,i        
         BRNE    feuerr      
         ADDX    1,i         
         BR      parafeu     
feuerr:  STRO    msgerf,d    
         call    fctcarte 
         charo   '\n',i
         STRO    msgfeu,d   
         call    vidfeu
         ldx     0,i
         CALL    missile
         CALL    restst     
         BR      parafeu     

;sous-programme pour reset le tableau des missiles
vidfeu:  ldx 0,i
vid:     ldbytea tabfeu,x
         cpa 0,i
         brne zero
         ret0
         
zero:    lda 0,i
         stbytea tabfeu,x
         addx 1,i
         br vid
         
       
feu:     CALL    locfeu      
         LDBYTEA colfeu,d    
         SUBA    62,i        
         STA     icol,d      
         LDBYTEA numfeu,d    
         SUBA    49,i        
         STA     irang,d     
         LDA     0,i         
         STA     temp,d      
         LDX     icol,d      
tirs:    CPA     irang,d     
         BREQ    confirm     
         ADDX    22,i        
         ADDA    1,i         
         BR      tirs        
confirm: CALL    testtir     
nexttir: LDX     indexfeu,d  
         ADDX    1,i         
         LDBYTEA tabfeu,x    
         CPA     0,i         
         BRNE    nouvtir     
         RET0   

;partie pour vérifier si un tir frappe un bateau               
nouvtir: CALL    fctcarte
         ADDX    1,i         
         BR      tirsuite    
testtir: LDBYTEA carte,x     
         STBYTEX indextir,d  
         CPA     '>',i       
         BREQ    touche      
         CPA     'V',i       
         BREQ    touche      
         CPA     '~',i       
         BREQ    coule       
         RET0                
touche:  LDBYTEA '*',i       
         STBYTEA carte,x     
         CALL    recur1      
         RET0                
coule:   LDBYTEA 'o',i       
         STBYTEA carte,x     
         RET0

;sous-programme pour la récursivité des tirs                 
recur1:  ADDX    1,i         
         CALL    testtir     
         LDBYTEX indextir,d  
         SUBX    1,i         
         CALL    testtir     
         LDBYTEX indextir,d  
         ADDX    22,i        
         CALL    testtir     
         LDBYTEX indextir,d  
         SUBX    22,i        
         CALL    testtir     
         LDBYTEX indextir,d  
         CALL    recur2      
         RET0                
recur2:  SUBX    1,i         
         CALL    testtir     
         LDBYTEX indextir,d  
         ADDX    1,i         
         CALL    testtir     
         LDBYTEX indextir,d  
         SUBX    22,i        
         CALL    testtir     
         LDBYTEX indextir,d  
         ADDX    22,i        
         CALL    testtir     
         RET0 

               
tstvie:  LDX     0,i         
agvie:   LDBYTEA carte,x     
         CPA     'V',i       
         BREQ    auttir      
         CPA     '>',i       
         BREQ    auttir      
         CPA     '\x00',i    
         BREQ    ret         
         ADDX    1,i         
         BR      agvie       
auttir:  CALL    restst      
         CALL    loopfeu     
         BR      more        
loopfeu: LDBYTEA tabfeu,x    
         CPA     '\x00',i    
         BRNE    resetfeu    
         BR      ret         
resetfeu:LDBYTEA 0,i         
         STBYTEA tabfeu,x    
         CHARO   tabfeu,x    
         ADDX    1,i         
         BR      loopfeu     
horsbat: call    enlevbat 
         BR      nextbat    
enlevbat:addx 1,i
         ldbytea tabbat,x
         cpa 0,i
         breq retirer
         cpa 32,i 
         breq retirer
         ldbytea tabbat,x
         addx 1,i
         cpa 0,i
         breq retirer
         ldbytea tabbat,x
         cpa 32,i 
         breq retirer
         addx 1,i
         ldbytea tabbat,x
         cpa 0,i
         breq retirer
         cpa 32,i
         breq retirer
         
retirer: subx 1,i
         ldbytea 32,i
         stbytea tabbat,x
         subx 1,i
         ldbytea 32,i
         stbytea tabbat,x
         subx 1,i
         stbytea tabbat,x
         subx 1,i
         stbytea tabbat,x
         ret0    
superpos:RET0 

;sous-programme pour mettre en mémoire les paramètres des missiles                
locfeu:  LDBYTEA tabfeu,x    
         STBYTEA colfeu,d    
         ADDX    1,i         
         LDBYTEA tabfeu,x    
         STBYTEA numfeu,d    
         STX     indexfeu,d  
         RET0  

;sous-programme pour mettre en mémoire les paramétres d'un bateau  
add1:    addx 1,i  
         br parambat           
parambat:LDBYTEA tabbat,x
         cpa 32,i
         breq add1
         cpa 0,i
         breq finpara
 
cont:    STBYTEA grandbat,d  
         ADDX    1,i         
         LDBYTEA tabbat,x    
         STBYTEA orienbat,d  
         ADDX    1,i         
         LDBYTEA tabbat,x    
         STBYTEA colbat,d    
         ADDX    1,i         
         LDBYTEA tabbat,x    
         STBYTEA rangbat,d   
         STX     indexbat,d  
         RET0  

;sous-programmme pour demander à l'utilisateur de rejouer ou de quitter                
rejouer: CHARI   play,d      
         LDBYTEA play,d      
         CPA     '\n',i      
         BREQ    rej         
         BR      end         
rej:     CALL    loopfeu     
         CALL    loopbat     
         BR      err         
end:     STRO    fin,d       
         STOP                
msgacc:  .ASCII  "Bienvenue au jeu de bataille navale!\x00"
cartetop:.ASCII  "\n  ABCDEFGHIJKLMNOPQR\x00"
carte:   .ASCII  "\n1|~~~~~~~~~~~~~~~~~~|"
         .ASCII  "\n2|~~~~~~~~~~~~~~~~~~|"
         .ASCII  "\n3|~~~~~~~~~~~~~~~~~~|"
         .ASCII  "\n4|~~~~~~~~~~~~~~~~~~|"
         .ASCII  "\n5|~~~~~~~~~~~~~~~~~~|"
         .ASCII  "\n6|~~~~~~~~~~~~~~~~~~|"
         .ASCII  "\n7|~~~~~~~~~~~~~~~~~~|"
         .ASCII  "\n8|~~~~~~~~~~~~~~~~~~|"
         .ASCII  "\n9|~~~~~~~~~~~~~~~~~~|\x00"
placebat:.ASCII  "\nEntrer la description et la position des bateaux"
         .ASCII  "\nselon le format suivant, séparés par des espaces:"
         .ASCII  "\ntaille[p/m/g] orientation[h/v] colonne[A-R] rangée[1-9]\n"
         .ASCII  "ex: ghC4 mvM2 phK9\n\x00"
errplace:.ASCII  "Erreur de format/parametre d'entrée des bateaux\x00"
msghors: .ASCII  "Un des bateaux est en dehors de la carte, veuillez recommencer.\n\x00"
msgsup:  .ASCII  "Au moins deux bateaux se superposent, veuillez recommencer.\x00"
fin:     .ASCII  "Merci d'avoir jouer!\x00"
msgfeu:  .ASCII  "\nFeu à volonté!\n(entrer les coups à tirer: colonne [A-R] rangée [1-9])"
         .ASCII  "\nex: A3 I5 M3\n\x00"
msgerf:  .ASCII  "Tirs invalide veuillez recommencer.\x00"
msgtirs: .ASCII  "Il reste des bateaux à tirer!\x00"
msgfin:  .ASCII  "\nVous avez anéanti la flotte! Appuyer sur enter pour jouer à nouveau ou n'importe quelle autre saisie pour quitter.\n\x00"
tabbat:  .BLOCK  50          ;#1d50a
tabfeu:  .BLOCK  50          ;#1d50a
choixfeu:.BYTE   0           
choixbat:.BYTE   0           
batlong: .EQUATE 50          
misslong:.EQUATE 30          
lettre:  .EQUATE 22          
rtrChari:.BYTE   0           
;mettre en memoire la grandeur du bateau
grandbat:.BYTE   0           
;mettre en memoire l'orientation du bateau
orienbat:.BYTE   0           
;mettre en memoire la colonne du bateau
colbat:  .BYTE   0           
;mettre en memoire la rangee du bateau
rangbat: .BYTE   0           
;mettre en memoire le nb de bateau
nbbat:   .WORD   0           
indexbat:.WORD   0           
indexfeu:.WORD   0           
;index de la rangee et colonne pour placer le bateau ou le missile
irang:   .WORD   0           
icol:    .WORD   0           
temp:    .WORD   0           
incrmbat:.WORD   0           
;param tirs
colfeu:  .BYTE   0           
numfeu:  .BYTE   0           
play:    .BYTE   0           
indextir:.BYTE   0           
tmpibat: .BLOCK  1           ;#1d1a
boucl:   .BLOCK  1           ;#1d1a
         .END                  