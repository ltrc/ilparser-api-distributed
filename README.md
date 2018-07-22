# ilparser-api-distributed
Repo for seting up a distributed version of ilparser-api using docker

Refer [ddag-sample](https://github.com/nehaljwani/ddag-sample) for the setup of docker swarm.

All containers related to this project can be either built from the Dockerfiles provided for each modules, or can be pulled from: [ltrc-public-docker-repo](https://hub.docker.com/u/ltrc/)

## Initialize all submodules
```bash
git submodule update --recursive --init
```
## Setting up containers
- While setting up docker containers, make sure that the name of the container is specified, and that is used while POSTing the graph to the public API container
- Containers can be setup like this:

```bash
$ docker run --net ddag --name common.computevibhakti --hostname common.computevibhakti -dit ltrc/ilparser-common-computevibhakti
$ docker run --net ddag --name hin.dependencyparse --hostname hin.dependencyparse -dit ltrc/ilparser-hin-dependencyparse
$ docker run --net ddag --name hin.tokenizer --hostname hin.tokenizer -dit ltrc/ilparser-hin-tokenize
$ docker run --net ddag --name hin.utf2wx --hostname hin.utf2wx -dit ltrc/ilparser-hin-utf2wx
$ docker run --net ddag --name hin.chunker --hostname hin.chunker -dit ltrc/ilparser-hin-chunker
$ docker run --net ddag --name hin.morph --hostname hin.morph -dit ltrc/ilparser-hin-morph
$ docker run --net ddag --name hin.guessmorph --hostname hin.guessmorph -dit ltrc/ilparser-hin-guessmorph
$ docker run --net ddag --name common.pickonemorph --hostname common.pickonemorph -dit ltrc/ilparser-common-pickonemorph                                                                       
$ docker run --net ddag --name common.computehead --hostname common.computehead -dit ltrc/ilparser-common-computehead
$ docker run --net ddag --name hin.postagger --hostname hin.postagger -dit ltrc/ilparser-hin-postagger
$ docker run --net ddag --name hin.pruning --hostname hin.pruning -dit ltrc/ilparser-hin-pruning
$ docker run --net ddag --name public --hostname public -dit ltrc/ilparser-public
```

## Sample run
- Create the file `/tmp/input.txt` with the following content:

```bash
   {
  "edges": {
    "input1": [
      "hin.tokenizer_1"
    ],
    "hin.tokenizer_1": [
      "hin.utf2wx_1"
    ],
    "hin.utf2wx_1": [
      "hin.morph_1"
    ],
    "hin.morph_1": [
      "hin.postagger_1"
    ],
    "hin.postagger_1": [
      "hin.chunker_1"
    ],
    "hin.chunker_1": [
      "hin.pruning_1"
    ],
    "hin.pruning_1": [
      "hin.guessmorph_1"
    ],
    "hin.guessmorph_1": [
      "common.pickonemorph_1"
    ],
    "common.pickonemorph_1": [
      "common.computehead_1"
    ],
    "common.computehead_1": [
      "common.computevibhakti_1"
    ],
    "common.computevibhakti_1": [
      "hin.dependencyparse_1"
    ]
   },
  "data": {
    "input1": "देश के टूरिजम में राजस्थान"
    }
   }
```
- To query, first find out the public IP of the public container, and then:

```bash
curl -s -H Expect: 172.18.0.14 --data "@/tmp/input.txt"  | jq . | sed -e 's/\\t/\t/g' -e 's/\\n/\n/g'  -e 's/\\"/\"/g' -e 's/^"//' -e 's/"$//'
{
  "hin.utf2wx": "<Sentence id="1">
1	xeSa	unk
2	ke	unk
3	tUrijama	unk
4	meM	unk
5	rAjasWAna	unk
</Sentence>
",
  "common.computehead": "<Sentence id="1">
1	((	NP	<fs af='xeSa,n,m,sg,3,o,0,0' head=xeSa>
1.1	xeSa	NN	<fs af='xeSa,n,m,sg,3,o,0,0' name=xeSa>
1.2	ke	PSP	<fs af='kA,psp,m,sg,,o,kA,kA' name=ke>
	))		
2	((	NP	<fs af='tUrijama,n,m,sg,3,o,0,0' head=tUrijama>
2.1	tUrijama	NN	<fs af='tUrijama,n,m,sg,3,o,0,0' name=tUrijama>
2.2	meM	PSP	<fs af='meM,psp,,,,,,' name=meM>
	))		
3	((	NP	<fs af='rAjasWAna,n,m,pl,3,d,0,0' head=rAjasWAna>
3.1	rAjasWAna	NNP	<fs af='rAjasWAna,n,m,pl,3,d,0,0' name=rAjasWAna>
	))		
</Sentence>
",
  "common.computevibhakti": "<Sentence id="1">
1	((	NP	<fs af='xeSa,n,m,sg,3,o,0_kA,0' head=xeSa vpos="vib1_2">
1.1	xeSa	NN	<fs af='xeSa,n,m,sg,3,o,0,0' name=xeSa>
1.2	ke	PSP	<fs af='kA,psp,m,sg,,o,kA,kA' name=ke>
	))		
2	((	NP	<fs af='tUrijama,n,m,sg,3,o,0_meM,0' head=tUrijama vpos="vib1_2">
2.1	tUrijama	NN	<fs af='tUrijama,n,m,sg,3,o,0,0' name=tUrijama>
2.2	meM	PSP	<fs af='meM,psp,,,,,,' name=meM>
	))		
3	((	NP	<fs af='rAjasWAna,n,m,pl,3,d,0,0' head=rAjasWAna>
3.1	rAjasWAna	NNP	<fs af='rAjasWAna,n,m,pl,3,d,0,0' name=rAjasWAna>
	))		
</Sentence>
",
  "hin.morph": "<Sentence id="1">
1	xeSa	unk	<fs af='xeSa,n,m,sg,3,d,0,0'>|<fs af='xeSa,n,m,pl,3,d,0,0'>|<fs af='xeSa,n,m,sg,3,o,0,0'>
2	ke	unk	<fs af='kA,psp,m,sg,,o,kA,kA'>|<fs af='kA,psp,m,pl,,d,kA,kA'>|<fs af='kA,psp,m,pl,,o,kA,kA'>
3	tUrijama	unk	<fs af='tUrijama,n,m,sg,3,d,0,0'>|<fs af='tUrijama,n,m,pl,3,d,0,0'>|<fs af='tUrijama,n,m,sg,3,o,0,0'>
4	meM	unk	<fs af='meM,psp,,,,,,'>
5	rAjasWAna	unk	<fs af='rAjasWAna,n,m,sg,3,d,0,0'>|<fs af='rAjasWAna,n,m,pl,3,d,0,0'>|<fs af='rAjasWAna,n,m,sg,3,o,0,0'>
</Sentence>
",
  "hin.tokenizer": "<Sentence id="1">
1	देश	unk
2	के	unk
3	टूरिजम	unk
4	में	unk
5	राजस्थान	unk
</Sentence>",
  "hin.pruning": "<Sentence id="1">
1	((	NP	
1.1	xeSa	NN	<fs af='xeSa,n,m,sg,3,d,0,0'>|<fs af='xeSa,n,m,pl,3,d,0,0'>|<fs af='xeSa,n,m,sg,3,o,0,0'>
1.2	ke	PSP	<fs af='kA,psp,m,sg,,o,kA,kA'>|<fs af='kA,psp,m,pl,,d,kA,kA'>|<fs af='kA,psp,m,pl,,o,kA,kA'>
	))		
2	((	NP	
2.1	tUrijama	NN	<fs af='tUrijama,n,m,sg,3,d,0,0'>|<fs af='tUrijama,n,m,pl,3,d,0,0'>|<fs af='tUrijama,n,m,sg,3,o,0,0'>
2.2	meM	PSP	<fs af='meM,psp,,,,,,'>
	))		
3	((	NP	
3.1	rAjasWAna	NNP	<fs af='rAjasWAna,n,m,sg,3,d,0,0'>|<fs af='rAjasWAna,n,m,pl,3,d,0,0'>|<fs af='rAjasWAna,n,m,sg,3,o,0,0'>
	))		
</Sentence>
",
  "hin.chunker": "<Sentence id="1">
1	((	NP	
1.1	xeSa	NN	<fs af='xeSa,n,m,sg,3,d,0,0'>|<fs af='xeSa,n,m,pl,3,d,0,0'>|<fs af='xeSa,n,m,sg,3,o,0,0'>
1.2	ke	PSP	<fs af='kA,psp,m,sg,,o,kA,kA'>|<fs af='kA,psp,m,pl,,d,kA,kA'>|<fs af='kA,psp,m,pl,,o,kA,kA'>
	))		
2	((	NP	
2.1	tUrijama	NN	<fs af='tUrijama,n,m,sg,3,d,0,0'>|<fs af='tUrijama,n,m,pl,3,d,0,0'>|<fs af='tUrijama,n,m,sg,3,o,0,0'>
2.2	meM	PSP	<fs af='meM,psp,,,,,,'>
	))		
3	((	NP	
3.1	rAjasWAna	NNP	<fs af='rAjasWAna,n,m,sg,3,d,0,0'>|<fs af='rAjasWAna,n,m,pl,3,d,0,0'>|<fs af='rAjasWAna,n,m,sg,3,o,0,0'>
	))		
</Sentence>

",
  "common.pickonemorph": "<Sentence id="1">
1	((	NP	
1.1	xeSa	NN	<fs af='xeSa,n,m,sg,3,o,0,0'>
1.2	ke	PSP	<fs af='kA,psp,m,sg,,o,kA,kA'>
	))		
2	((	NP	
2.1	tUrijama	NN	<fs af='tUrijama,n,m,sg,3,o,0,0'>
2.2	meM	PSP	<fs af='meM,psp,,,,,,'>
	))		
3	((	NP	
3.1	rAjasWAna	NNP	<fs af='rAjasWAna,n,m,pl,3,d,0,0'>
	))		
</Sentence>
",
  "hin.dependencyparse": "1	देश	देश	n	NN	case-o|vib-०_का|psd-|chunkId-NP|pers-3|num-sg|tam-0|sem-|cp-|gen-m	3	r6	_	_
2	के	का	psp	PSP	case-o|vib-का|psd-|chunkId-NP|pers-|num-sg|tam-kA|sem-|cp-|gen-m	1	lwg__psp	_	_
3	टूरिजम	टूरिजम	n	NN	case-o|vib-०_में|psd-|chunkId-NP2|pers-3|num-sg|tam-0|sem-|cp-|gen-m	0	root	_	_
4	में	में	psp	PSP	case-|vib-|psd-|chunkId-NP2|pers-|num-|tam-|sem-|cp-|gen-	3	lwg__psp	_	_
5	राजस्थान	राजस्थान	n	NNP	case-d|vib-0|psd-|chunkId-NP3|pers-3|num-pl|tam-0|sem-|cp-|gen-m	0	root	_	_

",
  "hin.postagger": "<Sentence id="1">
1	xeSa	NN	<fs af='xeSa,n,m,sg,3,d,0,0'>|<fs af='xeSa,n,m,pl,3,d,0,0'>|<fs af='xeSa,n,m,sg,3,o,0,0'>
2	ke	PSP	<fs af='kA,psp,m,sg,,o,kA,kA'>|<fs af='kA,psp,m,pl,,d,kA,kA'>|<fs af='kA,psp,m,pl,,o,kA,kA'>
3	tUrijama	NN	<fs af='tUrijama,n,m,sg,3,d,0,0'>|<fs af='tUrijama,n,m,pl,3,d,0,0'>|<fs af='tUrijama,n,m,sg,3,o,0,0'>
4	meM	PSP	<fs af='meM,psp,,,,,,'>
5	rAjasWAna	NNP	<fs af='rAjasWAna,n,m,sg,3,d,0,0'>|<fs af='rAjasWAna,n,m,pl,3,d,0,0'>|<fs af='rAjasWAna,n,m,sg,3,o,0,0'>
</Sentence>
",
  "input1": "देश के टूरिजम में राजस्थान",
  "hin.guessmorph": "<Sentence id="1">
1	((	NP	
1.1	xeSa	NN	<fs af='xeSa,n,m,sg,3,o,0,0'>
1.2	ke	PSP	<fs af='kA,psp,m,sg,,o,kA,kA'>|<fs af='kA,psp,m,pl,,d,kA,kA'>|<fs af='kA,psp,m,pl,,o,kA,kA'>
	))		
2	((	NP	
2.1	tUrijama	NN	<fs af='tUrijama,n,m,sg,3,o,0,0'>
2.2	meM	PSP	<fs af='meM,psp,,,,,,'>
	))		
3	((	NP	
3.1	rAjasWAna	NNP	<fs af='rAjasWAna,n,m,pl,3,d,0,0'>|<fs af='rAjasWAna,n,m,sg,3,d,0,0'>
	))		
</Sentence>

}
```
