const CACHE='capital-ai-v37-rc5-2';
self.addEventListener('install',e=>{self.skipWaiting();e.waitUntil(caches.open(CACHE).then(c=>c.addAll(['/','/index.html','/manifest.webmanifest']).catch(()=>{})))});
self.addEventListener('activate',e=>e.waitUntil(Promise.all([self.clients.claim(),caches.keys().then(keys=>Promise.all(keys.filter(k=>k!==CACHE).map(k=>caches.delete(k))))])));
self.addEventListener('fetch',e=>{if(e.request.method!=='GET'||new URL(e.request.url).pathname.startsWith('/api/'))return;e.respondWith(fetch(e.request).then(r=>{const copy=r.clone();caches.open(CACHE).then(c=>c.put(e.request,copy));return r}).catch(()=>caches.match(e.request).then(r=>r||caches.match('/index.html'))))});
self.addEventListener('push',e=>{let d={};try{d=e.data?.json()||{}}catch(_){d={body:e.data?.text()||''}};e.waitUntil(self.registration.showNotification(d.title||'Capital AI',{body:d.body||'Nueva señal disponible',icon:'/icon.svg',badge:'/icon.svg',tag:d.tag||'capital-ai'}))});
self.addEventListener('notificationclick',e=>{e.notification.close();e.waitUntil(clients.matchAll({type:'window',includeUncontrolled:true}).then(ws=>ws[0]?ws[0].focus():clients.openWindow('/')))});
