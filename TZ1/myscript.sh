#!/bin/bash

# проверяем, что введено нужное количество аргументов
if [[ "$#" -ne 2 ]]; then
	echo "not enough arguments"
	exit 1
fi

in_dir=$1
out_dir=$2

# проверяем существование входной директории
if [[ ! -d "$in_dir" ]]; then
	echo "input directory does not exist"
	exit 1
fi

# создаем список файлов, находящийся непосредственно во входной директории
files=$(find "$in_dir" -maxdepth 1 -type f 2>/dev/null)
echo "	FILES ONLY IN INPUT_DIRECTORY:"
echo "$files"

# создаём список файлов, находящихся во входной директории и всех вложенных в неё
files2=$(find "$in_dir" -type f 2>/dev/null)
echo "	ALL FILES IN INPUT_DIRECTORY:"
echo "$files2"

# создаем список директорий, вложенных во входную директорию
dirs=$(find "$in_dir" -mindepth 1 -type d 2>/dev/null)
echo "	DIRECTORIES IN INPUT_DIRECTORY:"
echo "$dirs"

# проверяем существование выходной директории
if [[ ! -d "$out_dir" ]]; then
	echo "output directory does not exist"
	exit 1
fi

# создаем функцию копирования файлов из директории
f() {
	local in="$1"
	local out="$2"
 	shopt -s dotglob
	for file in "$in"/*; do
		# для вложенных директорий рекурсивно запускаем функцию
		if [[ -d "$file" ]]; then
			f "$file" "$out"
		elif [[ -f "$file" ]]; then
			name=$(basename "$file")
			dest="$out/$name"
			# проверяем имя файля на совпадения, при необходимости меняем
			if [[ -e "$dest" ]]; then
				counter=1
				while [[ -e "$out/$counter$name" ]]; do
					((counter++))
				done
				dest="$out/$counter$name"
			fi
			cp "$file" "$dest" 2>/dev/null
		fi
	done
}
f "$in_dir" "$out_dir"

echo "files successfully copied"
