#!/bin/bash 
ref=$1
sam=$2
vcf=$3
xmldir=$4
bcftools query -f'[%POS\t%REF\t%ALT\n]' $vcf > fix.vcf
bam=${sam%.sam}.bam
/Users/renyao/Desktop/all/my_code/samtools-1.9/samtools faidx $ref
picard CreateSequenceDictionary -R $ref
refname=$(grep '>' $ref | sed 's,>,,g')
/Users/renyao/Desktop/all/my_code/samtools-1.9/samtools view -b $sam -o $bam
/Users/renyao/Desktop/all/my_code/samtools-1.9/samtools index $bam
echo '#DisSTDV=Distance Standard Deviation' >>result.txt
echo 'Pos\tRef\tAlt\tDisSTDV'  >>result.txt
while read line
do
	pos=$(echo $line |cut -d ' ' -f1 )
	refbase=$(echo $line |cut -d ' ' -f2 )
	altbase=$(echo $line |cut -d ' ' -f3 )
	fixname=$pos$refbase$altbase
	echo "working on variant $fixname"
	region=$refname:$pos-$pos
	possam=$fixname.bam
	posxml=$fixname.xml
	posread='variant_read.txt'
	posposition='variant_pos.txt'
	poslen='variant_read_length.txt'
	/Users/renyao/Desktop/all/my_code/samtools-1.9/samtools view -h $bam $region -o $possam
	java -jar $xmldir -r $ref $possam -o $posxml
	tr 'q' '\n' < $posxml | grep "read-base=\"$altbase\"\ ref-index=\"$pos\"\ ref-base=\"$refbase\"" | tr '>' '\n' > $posread
	grep "read-base=\"$altbase\"\ ref-index=\"$pos\"\ ref-base=\"$refbase\"" $posread | cut -d ' ' -f2 |sed 's/read\-index\=//g' | sed 's,",,g'> $posposition
	grep -B1 '/align' $posread | grep 'ref-index' |cut -d ' ' -f2 |sed 's/read\-index\=//g'| sed 's,",,g'> $poslen
	stdv=$(python variant_position_mean_dv.py)
	echo $pos'\t'$refbase'\t'$altbase'\t'$stdv  >>result.txt
	rm $possam $posxml $posread $posposition $poslen
done < fix.vcf
rm *bam*







