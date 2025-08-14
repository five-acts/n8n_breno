const gulp = require('gulp');

// Esta tarefa copia os arquivos de ícones (png, svg) da pasta de origem
// para a pasta de destino 'dist', mantendo a estrutura de diretórios.
function copyIcons() {
	return gulp
		.src(['nodes/**/*.png', 'nodes/**/*.svg'])
		.pipe(gulp.dest('./dist/nodes/'));
}

// Define a tarefa 'build:icons' que pode ser chamada pelo seu package.json
gulp.task('build:icons', copyIcons);
