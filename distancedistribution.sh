#!/bin/bash 
bcftools query -f'[%POS\t%REF\t%ALT\n]' TEST.vcf > fix.vcf
ref=$1
sam=$2
bam=${sam%.sam}.bam
samtools faidx $ref
picard CreateSequenceDictionary -R $ref
refname=$(grep '>' $ref | sed 's,>,,g')
samtools view -b $sam -o $bam
samtools index $bam
echo $refname
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
	echo $region
	possam=$fixname.bam
	posxml=$fixname.xml
	posread='variant_read.txt'
	posposition='variant_pos.txt'
	poslen='variant_read_length.txt'
	samtools view $bam $region -o $possam
	java -jar /jvarkit/dist/biostar59647.jar -r $ref $possam -o $posxml
	sed -e $'s/\<read\>/\\\n/g' $posxml | grep "read-base=\"$altbase\"\ ref-index=\"$pos\"\ ref-base=\"$refbase\"" | sed -e $'s,\/\>\<,\\\n,g' > $posread
	grep "read-base=\"$altbase\"\ ref-index=\"$pos\"\ ref-base=\"$refbase\"" $posread | cut -d ' ' -f2 |sed 's/read\-index\=//g' | sed 's,",,g'> $posposition
	grep -B1 '/align' $posread | grep 'ref-index' |cut -d ' ' -f2 |sed 's/read\-index\=//g'| sed 's,",,g'> $poslen
	stdv=$(python varaintpostionsdv.py)
	echo $pos'\t'$refbase'\t'$altbase'\t'$stdv  >>result.txt
done < fix.vcf








