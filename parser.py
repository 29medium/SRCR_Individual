# res -> (tipo: rua : (latitude, longitude, [ligacoes]))

import pandas as pd
from math import sin, cos, sqrt, atan2
import re
import sys

sys.setrecursionlimit(10000)

dataset = pd.read_excel(r'dataset.xlsx')
res = dict()
res['Geral'] = dict()

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

        res['Geral'][rua] = [None, None, None, None]
        res['Geral'][rua][0] = dataset["Latitude"][i]
        res['Geral'][rua][1] = dataset["Longitude"][i]
        res['Geral'][rua][2] = list(temp)
        res['Geral'][rua][3] = dataset["CONTENTOR_TOTAL_LITROS"][i]

# Pontos

fp = open("pontos.pl", "w")

fp.write('%%ponto(Localizacao,Latitude,Longitude,[Ligacoes],Tipo,Capacidade)\n')

for tipo, infor in res.items():
    if tipo != 'Geral':
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

def inArcos(rua, l):
    for (rua1, rua2) in arcos:
        if (rua == rua1 and l == rua2) or (rua == rua2 and l == rua1):
            return True

    return False

def arcosRec(rua, lista):
    if lista:
        for l in lista:
            if l in res['Geral'] and not inArcos(rua, l):
                arcos.append((rua, l))
                distancia = calculaDistancia(
                    res['Geral'][rua][0], res['Geral'][rua][1], res['Geral'][l][0], res['Geral'][l][1])
                fa.write('arco(\'' + rua + '\',' + '\'' +
                            l + '\',' + str(distancia) + ').\n')

fa.write('%%arco(Ponto1,Ponto2,Distancia)\n')

arcos = list()

for rua, info in res['Geral'].items():
    arcosRec(rua, info[2])

fa.close()
