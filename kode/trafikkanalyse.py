
import pandas as pd
import statsmodels.api as sm
import matplotlib.pyplot as plt
import seaborn as sns

df = pd.read_excel('C:\\Users\\Mathi\\OneDrive\\Skrivebord\\Rprosjekter\\Trafikkulykke_570.xlsx')



df['Ulykkesdato'] = pd.to_datetime(df['Ulykkesdato'])
df['Ulykkestidspunkt'] = pd.to_datetime(df['Ulykkestidspunkt'], format = '%H:%M')
df['Stedsforhold'] = df['Stedsforhold'].astype('string')


tunnel_data = df.loc[df['Stedsforhold'] == 'Tunnel (primært for motorkjøretøy)']
tunnel_data2 = tunnel_data[tunnel_data['Alvorligste skadegrad'] != 'Ikke registrert']

alvorlighetsgrad = tunnel_data2['Alvorligste skadegrad'].value_counts()

plt.figure(figsize=(10, 8))
alvorlighetsgrad.plot(kind='bar', color='skyblue')
plt.title('Alvorlighetsgrad på ulykker i tuneller')
plt.xlabel('Alvorligste skadegrad')
plt.ylabel('Tilfeller')
for index, value in enumerate(alvorlighetsgrad):
    plt.text(index, value, str(value), ha='center', va='bottom')

plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.show()

'''tunnel_data3 = tunnel_data[tunnel_data['Lysforhold'] != 'Ukjent']

lysforhold = tunnel_data3['Lysforhold'].value_counts()

lysforhold.plot(kind='bar', color='skyblue')
plt.title('Ulykker under ulike lysforhold')
plt.xlabel('Lysforhold')
plt.ylabel('Tilfeller')
for index, value in enumerate(lysforhold):
    plt.text(index, value, str(value), ha='center', va='bottom')

plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.show()'''

'''fart_død_data = df[['Alvorligste skadegrad','Fartsgrense','Vegbredde']]

fart_død_data_tunnel = tunnel_data[['Alvorligste skadegrad','Fartsgrense','Vegbredde']]

fart_død_data['Dødsfall'] = fart_død_data['Alvorligste skadegrad'].apply(lambda x: 1 if x == 'Drept' else 0)

fart_død_data_tunnel['Dødsfall'] = fart_død_data_tunnel['Alvorligste skadegrad'].apply(lambda x: 1 if x == 'Drept' else 0)

fart_død_data = fart_død_data.drop(columns=['Alvorligste skadegrad'])

fart_død_data_tunnel = fart_død_data_tunnel.drop(columns=['Alvorligste skadegrad'])


fart_død_data = fart_død_data.dropna()

fart_død_data_tunnel = fart_død_data_tunnel.dropna()'''




def logisticalreg(data):


    Xtrain = data[['Vegbredde','Fartsgrense']]
    ytrain = data[['Dødsfall']]


    log_reg = sm.Logit(ytrain, Xtrain).fit()

    return log_reg.summary()



bar_chart_data = df.loc[
    (df['Stedsforhold'] == 'Tunnel (primært for motorkjøretøy)') |
    (df['Stedsforhold'] == '3-armet kryss (T-kryss, Y-kryss)') |
    (df['Stedsforhold'] == '4 armet kryss (X-kryss)') |
    (df['Stedsforhold'] == 'Avkjørsel') |
    (df['Stedsforhold'] == 'Rundkjøring')


]

bar_chart_data = bar_chart_data.loc[
    (df['Fartsgrense'] == 30) |
    (df['Fartsgrense'] == 40) |
    (df['Fartsgrense'] == 50) |
    (df['Fartsgrense'] == 60) |
    (df['Fartsgrense'] == 70) |
    (df['Fartsgrense'] == 80)
    ]

grouped_data = bar_chart_data.groupby(['Fartsgrense', 'Stedsforhold']).size().reset_index(name='Count')

grouped_data['Fartsgrense'] = grouped_data['Fartsgrense'].astype(int)


plt.figure(figsize=(10, 6))
sns.barplot(x= grouped_data['Fartsgrense'], y= grouped_data['Count'], hue= grouped_data['Stedsforhold'], data=grouped_data, palette='hls', edgecolor = 'black')

plt.title('Ulykkestilfeller gruppert etter fartsgrense og stedsforhold')
plt.xlabel('Fartsgrense')
plt.ylabel('Tilfeller')
plt.legend(title='Stedsforhold', title_fontsize='13')


plt.show()

colors = {'Tunnel (primært for motorkjøretøy)': '#a157db',
          '3-armet kryss (T-kryss, Y-kryss)': 'lightblue',
          '4 armet kryss (X-kryss)': 'lightblue',
          'Avkjørsel': 'lightblue',
          'Rundkjøring': 'lightblue'}



plt.figure(figsize=(10, 6))
sns.barplot(x= grouped_data['Fartsgrense'], y= grouped_data['Count'], hue= grouped_data['Stedsforhold'], data=grouped_data, palette = colors , edgecolor = 'black', legend = False)


plt.title('Økning i antall tunnelulykker som en funksjon av fartsgrense')
plt.xlabel('Fartsgrense')
plt.ylabel('Tilfeller')


plt.show()
