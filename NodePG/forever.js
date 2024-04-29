var localtunnel = require('localtunnel');

try {
	localtunnel(3300, { subdomain: 'keyadmin' }, function(err, tunnel) {
	console.log('localtunnel is running')
	});
} catch(exception) {
	console.log(exception);
}