# GeoTasks

Requires `docker-compose` or Elixir 1.10.4 to run locally.

### Build

```
$ docker-compose build
```

### Seed database

```
$ docker-compose run api bash /app/seed.sh

Starting geo-tasks-ex_db_1 ... done
-------- driver --------
user_id: 005a670d-f3c1-4c75-ae1f-68a992dd000f
token: OJEZ527kuslG8y93gv1iomHi7zUuouP9dJ45Y0h6qZw=
-------- manager --------
user_id: 76c3d4f6-4498-4c4c-90cb-329b98e2b764
token: 7TShrRqZwAyUN0lpQAv_3osbvHnMsbBig_-3BmrMK2Y=
```

### Start

```
$ docker-compose up
```

### Test

Make sure to use the user_id and token from seed output.

#### Create task
```
$ curl http://0.0.0.0:4000/api/manager/tasks \
  -X POST \
  --data-raw '{ "lat1": 1, "long1": 2, "lat2": 3, "long2": 4 }' \
  -H 'Content-Type: application/json' \
  -H 'X-Auth-Token: 7TShrRqZwAyUN0lpQAv_3osbvHnMsbBig_-3BmrMK2Y=' \
  -H 'X-User-Id: 76c3d4f6-4498-4c4c-90cb-329b98e2b764'
```

#### List tasks nearby
```
$ curl http://0.0.0.0:4000/api/driver/tasks-nearby\?lat\=1\&long\=2 \
  -H 'X-Auth-Token: OJEZ527kuslG8y93gv1iomHi7zUuouP9dJ45Y0h6qZw=' \
  -H 'X-User-Id: 005a670d-f3c1-4c75-ae1f-68a992dd000f'

# output
[{"id":1,"distance":0.0,"description":null}]
```

#### Assign task
```
$ curl http://0.0.0.0:4000/api/driver/task/1/assign \
  -X POST \
  -H 'X-Auth-Token: OJEZ527kuslG8y93gv1iomHi7zUuouP9dJ45Y0h6qZw=' \
  -H 'X-User-Id: 005a670d-f3c1-4c75-ae1f-68a992dd000f'

# output
{"status":"assigned","long2":4.0,"long1":2.0,"lat2":3.0,"lat1":1.0,"id":1,"description":null}
```

#### Complete task
```
$ curl http://0.0.0.0:4000/api/driver/task/1/complete \
  -X POST \
  -H 'X-Auth-Token: OJEZ527kuslG8y93gv1iomHi7zUuouP9dJ45Y0h6qZw=' \
  -H 'X-User-Id: 005a670d-f3c1-4c75-ae1f-68a992dd000f'

# output
{"status":"done","long2":4.0,"long1":2.0,"lat2":3.0,"lat1":1.0,"id":1,"description":null}
```
