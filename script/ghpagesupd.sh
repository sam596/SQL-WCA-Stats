#!/bin/bash

# Link to mysql password
source ~/.mysqlpw/mysql.conf

# bestaveragewithoutsubxsingle

declare -a arr=(5 6 7 8 9 10)

for i in "${arr[@]}"
do
	echo "Best Average without Sub ${i} Single"
	mysql -u sam -p"$mysqlpw" wca_dev -e "SELECT CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',a.personId,')') Name, p.countryId Country, (SELECT ROUND(best/100,2) FROM rankssingle WHERE eventId = '333' AND personId = a.personId) Single, ROUND(a.best/100,2) Average FROM ranksaverage a INNER JOIN persons p ON p.subid = 1 AND a.personId = p.id WHERE a.eventId = '333' AND personId NOT IN (SELECT personId FROM rankssingle WHERE eventId = '333' AND best < ${i}00) ORDER BY average ASC, Single ASC, personId LIMIT 250;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	output=$(cat ~/mysqloutput/output)
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
	cp ~/pages/WCA-Stats/templates/bestaveragewithoutsubxsingle.md ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/sub$i.md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/sub$i.md.tmp
	awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/sub$i.md.tmp > ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/sub$i.md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/sub$i.md.tmp2 > ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/sub$i.md
	rm ~/pages/WCA-Stats/bestaveragewithoutsubxsingle/*.tmp*
done

# bestpodiums

declare -a arr=(333 222 444 555 666 777 333bf 333fm 333oh 333ft clock minx pyram skewb sq1 444bf 555bf 333mbf)

for i in "${arr[@]}"
do
	echo "Best ${i} Podiums"
	mysql -u sam -p"$mysqlpw" wca_stats -e "SELECT CONCAT('[',competitionId,'](https://www.worldcubeassociation.org/competitions/',competitionId,')') Competition, \
com.countryId Country, \
IF('${i}' = '333mbf', CONCAT(297-SUM(LEFT(result,2))+SUM(RIGHT(result,2)),'/',297-SUM(LEFT(result,2))+(2*SUM(RIGHT(result,2))),' ',LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(MID(result,4,4))),'%H:%i:%s'),8)), IF('${i}' = '333fm',SUM(ROUND(result/100,2)),IF( SUM(result) >= 360000, LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),'%H:%i:%s.%f'),11), IF( SUM(result) >= 6000, IF( SUM(result) < 60000, RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),'%i:%s.%f'),8),7), LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),'%i:%s.%f'),8)), IF( SUM(result) < 1000, RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),'%s.%f'),5),4), LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(result/100)),'%s.%f'),5)))))) sum, \
GROUP_CONCAT(CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',personId,')') SEPARATOR ', ') Podiummers, \
GROUP_CONCAT(IF('${i}'='333mbf',CONCAT(99-LEFT(result,2)+RIGHT(result,2),'/',99-LEFT(result,2)+(2*RIGHT(result,2)),' ',LEFT(TIME_FORMAT(SEC_TO_TIME(MID(result,4,4)),'%H:%i:%s'),8)),IF( result >= 360000, LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),'%H:%i:%s.%f'),11), IF( result >= 6000, IF( result < 60000, RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),'%i:%s.%f'),8),7), LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),'%i:%s.%f'),8)), IF(result < 1000, RIGHT(LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),'%s.%f'),5),4), LEFT(TIME_FORMAT(SEC_TO_TIME(result/100),'%s.%f'),5))))) SEPARATOR ', ') Results \
FROM (SELECT competitionId, eventId, pos, personId, personname, (CASE WHEN eventId LIKE '%bf' THEN best ELSE average END) result FROM podiums WHERE (CASE WHEN eventId LIKE '%bf' THEN best ELSE average END) > 0) a \
JOIN wca_dev.persons p ON a.personId = p.id AND p.subid = 1 \
JOIN wca_dev.competitions com ON a.competitionid = com.id \
WHERE eventId = '${i}' \
GROUP BY competitionId, eventId HAVING COUNT(*) = 3 \
ORDER BY SUM(result), com.start_date ASC LIMIT 1000;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
    sed -i.bak '2i\
--|--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
    date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/bestpodiums.md ~/pages/WCA-Stats/bestpodiums/$i.md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/bestpodiums/$i.md.tmp
	awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/bestpodiums/$i.md.tmp > ~/pages/WCA-Stats/bestpodiums/$i.md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/bestpodiums/$i.md.tmp2 > ~/pages/WCA-Stats/bestpodiums/$i.md && \
	rm ~/pages/WCA-Stats/bestpodiums/*.tmp*
done

#pbstreaks

declare -a arr=(pb_streak pb_streak_exfmc pb_streak_exfmcbld)

for i in "${arr[@]}"
do
	if [ "$i" = "pb_streak" ]; then text=$(echo "PB Streak")
	elif [ "$i" = "pb_streak_exfmc" ]; then text=$(echo "PB Streak excluding FMC-Only Comps")
	elif [ "$i" = "pb_streak_exfmcbld" ]; then text=$(echo "PB Streak excluding FMC-and-BLD-Only Comps")
	fi
	echo "Longest ${i}"
	mysql -u sam -p"$mysqlpw" wca_stats -e "SELECT CONCAT('[',p.name,'](https://www.worldcubeassociation.org/persons/',a.personId,')') name, a.pbStreak \`PB Streak\`, CONCAT('[',a.startcomp,'](https://www.worldcubeassociation.org/competitions/',a.startcomp,')') \`Start Comp\`, IF((SELECT id FROM ${i} WHERE personId = a.personId AND endcomp = a.endComp)=(SELECT MAX(id) FROM ${i} WHERE personId = a.personId),'',CONCAT('[',(SELECT competitionId FROM ${i} WHERE id = a.id + 1),'](https://www.worldcubeassociation.org/competitions/',(SELECT competitionId FROM ${i} WHERE id = a.id + 1),')' )) \`End Comp\` FROM ${i} a INNER JOIN (SELECT personId, startcomp, MAX(pbStreak) maxpbs FROM ${i} GROUP BY personId, startcomp) b ON a.personId = b.personId and a.startcomp = b.startcomp and b.maxpbs = a.pbstreak JOIN wca_dev.persons p ON a.personId = p.id ORDER BY a.pbStreak DESC, personId LIMIT 1000;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
    cp ~/pages/WCA-Stats/templates/pbstreak.md ~/pages/WCA-Stats/pbstreaks/$i.md.tmp
    cat ~/mysqloutput/output >> ~/pages/WCA-Stats/pbstreaks/$i.md.tmp
    awk -v r="$text" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/pbstreaks/$i.md.tmp > ~/pages/WCA-Stats/pbstreaks/$i.md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/pbstreaks/$i.md.tmp2 > ~/pages/WCA-Stats/pbstreaks/$i.md && \
	rm ~/pages/WCA-Stats/pbstreaks/*.tmp*
done

#mostsubxsinglewithoutsubxaverage

declare -a arr=(6 7 8 9 10)

for i in "${arr[@]}"
do
	echo "Most Sub-${i} Singles without a Sub-${i} Average"
	mysql -u sam -p"$mysqlpw" wca_stats -e "SELECT CONCAT('[',personname,'](https://www.worldcubeassociation.org/persons/',personId,')') Name, COUNT(*) \`Sub-${i}s\`, (SELECT ROUND(best/100,2) FROM wca_dev.ranksaverage WHERE personId = a.personId AND eventId = '333') Average FROM wca_stats.all_single_results a WHERE value > 0 AND value < ${i}00 AND eventId = '333' AND personId NOT IN (SELECT personId FROM wca_dev.ranksaverage WHERE eventId = '333' AND best < ${i}00) GROUP BY personId ORDER BY COUNT(*) DESC, Average LIMIT 250;" > ~/mysqloutput/original && \
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output && \
	sed -i.bak '2i\
--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
	cp ~/pages/WCA-Stats/templates/mostsubxsinglewithoutsubxaverage.md ~/pages/WCA-Stats/mostsubxsinglewithoutsubxaverage/$i.md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/mostsubxsinglewithoutsubxaverage/$i.md.tmp
    awk -v r="$i" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/mostsubxsinglewithoutsubxaverage/$i.md.tmp > ~/pages/WCA-Stats/mostsubxsinglewithoutsubxaverage/$i.md.tmp2 && \
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/mostsubxsinglewithoutsubxaverage/$i.md.tmp2 > ~/pages/WCA-Stats/mostsubxsinglewithoutsubxaverage/$i.md && \
	rm ~/pages/WCA-Stats/mostsubxsinglewithoutsubxaverage/*.tmp*
done

#sumofbesttimesatcompetition

declare -a arr=(all ex45bf)

for i in "${arr[@]}"
do
	echo "Sum of times at competition ${i}"
	if [ "$i" = "all" ]; 
		then 
			text=$(echo "All competitions excluding MBLD and FMC")
			mysql -u sam -p"$mysqlpw" wca_dev -e "SELECT CONCAT('[',competitionId,'](https://www.worldcubeassociation.org/competitions/',competitionId,')') Competition, (SELECT countryId FROM competitions WHERE id = a.competitionId) Country, LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(best)/100),'%i:%s.%f'),8) \`Sum\` FROM (SELECT competitionId, eventId, MIN(best) best FROM results WHERE competitionId IN (SELECT competitionId FROM results WHERE eventId IN ('333','222','444','555','666','777','333oh','333bf','333ft','clock','skewb','pyram','minx','sq1','444bf','555bf') AND best > 0 GROUP BY competitionId HAVING COUNT(DISTINCT eventId) = 16) AND best > 0 AND eventId NOT IN ('333mbf','333fm') GROUP BY competitionId, eventId) a GROUP BY competitionId ORDER BY SUM(best) ASC, competitionId LIMIT 500;" > ~/mysqloutput/original
		else 
			text=$(echo "All competitions excluding MBLD, FMC, 4BLD and 5BLD")
			mysql -u sam -p"$mysqlpw" wca_dev -e "SELECT CONCAT('[',competitionId,'](https://www.worldcubeassociation.org/competitions/',competitionId,')') Competition, (SELECT countryId FROM competitions WHERE id = a.competitionId) Country, LEFT(TIME_FORMAT(SEC_TO_TIME(SUM(best)/100),'%i:%s.%f'),8) \`Sum\` FROM (SELECT competitionId, eventId, MIN(best) best FROM results WHERE competitionId IN (SELECT competitionId FROM results WHERE eventId IN ('333','222','444','555','666','777','333oh','333bf','333ft','clock','skewb','pyram','minx','sq1') AND best > 0 GROUP BY competitionId HAVING COUNT(DISTINCT eventId) = 14) AND best > 0 AND eventId NOT IN ('333mbf','333fm','444bf','555bf') GROUP BY competitionId, eventId) a GROUP BY competitionId ORDER BY SUM(best) ASC LIMIT 500;" > ~/mysqloutput/original
	fi
	sed 's/\t/|/g' ~/mysqloutput/original > ~/mysqloutput/output
	sed -i.bak '2i\
--|--|--\' ~/mysqloutput/output
	sed -i.bak 's/^/|/' ~/mysqloutput/output
	sed -i.bak 's/$/|  /' ~/mysqloutput/output
	date=$(date -r ~/databasedownload/wca-developer-database-dump.zip +"%a %b %d at %H%MUTC")
	cp ~/pages/WCA-Stats/templates/sumbesttime.md ~/pages/WCA-Stats/sumbesttime/$i.md.tmp
	cat ~/mysqloutput/output >> ~/pages/WCA-Stats/sumbesttime/$i.md.tmp
	awk -v r="$text" '{gsub(/xxx/,r)}1' ~/pages/WCA-Stats/sumbesttime/$i.md.tmp > ~/pages/WCA-Stats/sumbesttime/$i.md.tmp2
	awk -v r="$date" '{gsub(/today_date/,r)}1' ~/pages/WCA-Stats/sumbesttime/$i.md.tmp2 > ~/pages/WCA-Stats/sumbesttime/$i.md
	rm ~/pages/WCA-Stats/sumbesttime/*.tmp*
done

d=$(date +%Y-%m-%d)
cd ~/pages/WCA-Stats/ && git add -A && git commit -m "${d} update" && git push origin gh-pages
