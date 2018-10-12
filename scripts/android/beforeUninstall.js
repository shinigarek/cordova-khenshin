module.exports = function(ctx) {
	var fs = ctx.requireCordovaModule('fs'),
		path = ctx.requireCordovaModule('path');

	var colorsPath = path.join(ctx.opts.projectRoot, 'platforms/android/app/src/main/res/values/khenshincolors.xml');

	fs.unlinkSync(colorsPath);

};
