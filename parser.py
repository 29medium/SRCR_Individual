# res -> (tipo: rua : (latitude, longitude, [ligacoes]))

import pandas as pd
from math import sin, cos, sqrt, atan2
import re
import sys

sys.setrecursionlimit(10000)

dataset = pd.read_excel(r'dataset.xlsx')
res = dict()

dataset['PONTO_RECOLHA_FREGUESIA'] = dataset['PONTO_RECOLHA_FREGUESIA'].str.normalize('NFKD').str.encode('ascii', errors='ignore').str.decode('utf-8')
dataset['PONTO_RECOLHA_LOCAL'] = dataset['PONTO_RECOLHA_LOCAL'].str.normalize('NFKD').str.encode('ascii', errors='ignore').str.decode('utf-8')
dataset['CONTENTOR_RESÍDUO'] = dataset['CONTENTOR_RESÍDUO'].str.normalize('NFKD').str.encode('ascii', errors='ignore').str.decode('utf-8')

recolhaRE = re.compile(r'([a-zA-Z ]+)(\(.+\))?')

for i in range(0, dataset['OBJECTID'].size - 1):
    tipo = dataset["CONTENTOR_RESÍDUO"][i]

    if tipo not in res:
        res[tipo] = dict()

    recolha = re.search(recolhaRE, dataset["PONTO_RECOLHA_LOCAL"][i]).groups()
    rua = recolha[0].strip()
    
    if rua not in res[tipo]:
        res[tipo][rua] = [None, None, None, None]
        res[tipo][rua][0] = dataset["Latitude"][i]
        res[tipo][rua][1] = dataset["Longitude"][i]

        if recolha[1]:
            lixo = re.search(r':(.+)\)', recolha[1]).groups()
            ligacoes = re.split(r' - ', lixo[0].strip())
            
            if ligacoes:
                temp = set()
                for l in ligacoes:
                    temp.add(l)
                res[tipo][rua][2] = list(temp)
        
        res[tipo][rua][3] = dataset["CONTENTOR_TOTAL_LITROS"][i]

# Pontos

fp = open("pontos.pl", "w")

fp.write('%%ponto(Localizacao,Latitude,Longitude,[Ligacoes],Tipo,Capacidade)\n')

for tipo, infor in res.items():
    for rua, info in infor.items():
        ligacoes = '[]'

        if info[2]:
            ligacoes = '['
            for i in range(0,len(info[2])-1):
                ligacoes += '\'' + info[2][i] + '\','
            ligacoes += '\'' + info[2][-1] + '\']'

        fp.write('ponto(' + '\'' + rua + '\','
                            + str(info[0]) + ','
                            + str(info[1]) + ','
                            + ligacoes + ','
                            + '\'' + tipo + '\','
                            + str(info[3]) + ').\n')

fp.close()

# Arcos

fa = open("arcos.pl", "w")

def calculaDistancia(lat1, lat2, lon1, lon2):
    R = 6373.0

    dlon = lon2 - lon1
    dlat = lat2 - lat1

    a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))

    return R * c

visitados = dict()
vis = dict()

def inVisitados(rua1, rua2, tipo):
    if tipo in visitados:
        for (rua, l, _) in visitados[tipo]:
            if (rua==rua1 and l==rua2) or (rua==rua2 and l==rua1):
                return True

    return False

def acrescentaVisitados(rua1, rua2, tipo):
    if tipo not in visitados:
        visitados[tipo] = list()
    visitados[tipo].append(
        (rua, l, calculaDistancia(res[tipo][rua1][0], res[tipo][rua1][1], res[tipo][rua2][0], res[tipo][rua2][1])))

def inVis(rua, tipo):
    if tipo in vis:
        if rua in vis[tipo]:
            return True
    return False

def acrescentaVis(rua, tipo):
    if tipo not in vis:
        vis[tipo] = set()
    vis[tipo].add(rua)

def arcosRec(rua, lista, tipo):
    if not inVis(rua, tipo):
        acrescentaVis(rua, tipo)
        if lista:
            for l in lista:
                if (l in res[tipo]):
                    if (not inVisitados(rua, l, tipo)):
                        acrescentaVisitados(rua, l, tipo)
                        nextRua = l
                    else:
                        nextRua = rua

                    arcosRec(nextRua, res[tipo][l][2], tipo)

for tipo in res:
    for rua, info in res[tipo].items():
        arcosRec(rua, info[2], tipo)

fa.write('%%arco(Ponto1,Ponto2,Distancia,Tipo)\n')

for tipo in res:
    if tipo in visitados:
        for [rua1, rua2, distancia] in visitados[tipo]:
            fa.write('arco(\'' + rua1 + '\','
                    + '\'' + rua2 + '\','
                    + str(distancia) + ','
                    + '\'' + tipo + '\''
                    + ')\n')

fa.close()

'''
arcos = set()



def inArcos(rua1, rua2, tipo):
    for arco in arcos:
        if ((arco[0] == rua1 and arco[1] == rua2) or (arco[1] == rua1 and arco[0] == rua2)) and arco[3] == tipo:
            return True

    print(len(arcos))

    return False

def temTipo(rua, tipo):
    return tipo in res[rua][3].keys()

def arcosRec(rua1, rua2, tipo, arcos):
    if rua2 in res.keys():
        if not inArcos(rua1, rua2, tipo):
            if temTipo(rua2, tipo):
                cenas = (rua1, rua2, calculaDistancia(
                    res[rua1][0], res[rua1][1], res[rua2][0], res[rua2][1]), tipo)
                arcos.add(cenas)

                nextRua = rua2
            else: 
                nextRua = rua1
            
            if res[rua2][2]:
                for l in res[rua2][2]:
                    arcosRec(nextRua, l, tipo, arcos)

for rua, info in res.items():
    if info[2]:
        for l in info[2]:
            for t in info[3].keys():
                arcosRec(rua, l, t, arcos)



'''
