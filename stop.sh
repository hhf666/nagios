id=`docker images|grep -v grep|grep none|awk '{print $3}'`
for i in $id
do 
docker rmi $id
done

id=`docker ps -a|grep -v CONTAINER|grep -v grep |awk '{print $1}'`
for i in $id
do
docker stop $id;docker rm $id
done

id=`docker ps -a|grep nagios|awk '{print $1}'`
docker stop $id;docker rm $id


