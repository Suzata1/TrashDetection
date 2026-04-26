const dns = require('dns');

const { Resolver } = dns.promises;
const resolver = new Resolver();
resolver.setServers(['8.8.8.8', '8.8.4.4']);

async function resolveSrv() {
  try {
    const srvRecords = await resolver.resolveSrv('_mongodb._tcp.cluster0.uxqy6jo.mongodb.net');
    console.log('SRV:', srvRecords);
    const txtRecords = await resolver.resolveTxt('cluster0.uxqy6jo.mongodb.net');
    console.log('TXT:', txtRecords);
    
    if (srvRecords.length > 0) {
      const hosts = srvRecords.map(r => `${r.name}:${r.port}`).join(',');
      const txt = txtRecords.flat().join('&');
      const uri = `mongodb://root:root@${hosts}/Project?${txt}&appName=Cluster0`;
      console.log('\nUSE THIS URI:\n');
      console.log(uri);
    }
  } catch (err) {
    console.error(err);
  }
}

resolveSrv();
