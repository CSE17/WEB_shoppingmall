const helpers = require('./helpers');
const kidsModel = require("../models/kids");
const kidslocationModel = require("../models/kidslocation");

// /kids/id/compare
exports.compare = function (req, res) {
    console.log('kids id compare connect');

    const kidsId = req.body['kidsId'];

    if(kidsId) {
        kidsModel.find({ kidsId: kidsId }, (err, data) => {
            if(err) console.log(err);

            if( Object.keys(data).length === 0 ) {
                var kids = new kidsModel({ kidsId: kidsId, key: null }); // make kids data form.
                kids.save(function (err, data) {});

                res.send( kidsId.toString() );
            }

            else {
                kidsModel.find({}, (err, data) => {
                    let savedId = helpers.makeRandomNumber(); // generate a new key when kidsId is duplicated from flutter.
                    let count = 0;
    
                    const length = data.length;
    
                    while( count < 1 ) { // to avoid duplication of kidsId, loop the function.
                        for( let i = 0; i < length; i++ ) {
                            if( data[i]['kidsId'] == savedId ) savedId = helpers.makeRandomNumber(); // if kidsId is duplicated, regenerate.
                            else count++;
                        }
                    }

                    var kids = new kidsModel({ kidsId: savedId, key: null }); // make kids data form.
                    kids.save(function (err, data) {}); // insert data.
    
                    res.send( savedId.toString() ); // throw kidsId not duplicated.
                });
            }
        })
    }

    else res.send('no id');
}

// /kids/key/create
exports.create = function (req, res) {
    console.log('create a key');

    const kidsId = req.body['kidsId'];

    if( kidsId ) {
        kidsModel.find({ kidsId: kidsId, key: null }, (err, data) => { // find case kidsId is existed and key value is null
            if( Object.keys(data).length === 0 ) res.send('no id or key exist');

            else {
                const key = helpers.keyGenerator();

                kidsModel.updateOne({ kidsId: kidsId }, { key: key }, { upsert: true }, function (err, data) {
                    if(err) console.log(err);
                    else {
                        console.log('key generated');

                        console.log('create kidslocation');
                        var kidslocation = new kidslocationModel({
                            parentsId: null,
                            kidsId: kidsId,
                            source: null,
                            destination: null,
                            lon: null,
                            lat: null,
                            start: null,
                            end: null,
                            polygon: null,
                            status: false,
                            date: null
                        }); // make kidslocation data form.
                        kidslocation.save(function (err, data) { if(err) console.log(err); else console.log(data); });
                    }
                });

                res.status(401).json({ 'result': 1, 'key': key });
            }
        });
    }

    else res.status(401).json({ 'result': 0, 'key': null });
}

// /kids/location/start
exports.start = function (req, res) { // 로컬의 플루터 디비에서 키값이 있는지 확인하고 이 쪽으로 들어옴.
    console.log('map start');

    const kidsId = req.body['kidsId'];
    const key = req.body['key'];

    if( kidsId && key ) {
        kidslocationModel.find({ kidsId: kidsId }, (err, kdata) => {
            if(err) console.log(err);
            console.log(kdata);

            const length = Object.keys(kdata).length;
            console.log(length);

            if( length === 0 ) { // 첫 길 찾기를 할 경우 kidslocation 데이터 폼을 만든다 혹은 부모앱에서 데이터를 다 가져가서 kidslocation가 없을 경우 생성.
                // console.log('create kidslocation');
                // var kidslocation = new kidslocationModel({
                //     parentsId: null,
                //     kidsId: kidsId,
                //     source: null,
                //     destination: null,
                //     lon: null,
                //     lat: null,
                //     start: null,
                //     end: null,
                //     polygon: null,
                //     status: false,
                //     date: null
                // }); // make kidslocation data form.
                // kidslocation.save(function (err, data) { if(err) console.log(err); else console.log(data); });
                // res.send('id is wrong');
            }

            if( kdata[length - 1]['status'] == false && kdata[length - 1]['polygon'] != null ) { // 한 번 이상의 길 찾기를 한 상태이고 새로운 길 찾기를 하는데 들어갈 데이터 폼이 없을 때.
                console.log('make new kidslocation');
                var kidslocation = new kidslocationModel({
                    parentsId: null,
                    kidsId: kidsId,
                    source: null,
                    destination: null,
                    lon: null,
                    lat: null,
                    start: null,
                    end: null,
                    polygon: null,
                    status: false,
                    date: null
                }); // make kidslocation data form.
                kidslocation.save(function (err, data) { if(err) console.log(err); else console.log(data); });
            }
            const source = req.body['source'];
            const destination = req.body['destination'];
            const polygon = req.body['polygon'];
            const start = req.body['start'];
            const end = req.body['end'];
            console.log(kdata);
            console.log(source);
            if( kdata[0]['status'] == false ) { // 처음으로 길 찾기를 시작 했을 때 초기 정보 업데이트.
                console.log('status is false');
                var moment = require('moment');
                var currentDate = moment().format('YYYY-MM-DD HH:mm');
                console.log( typeof(currentDate) );
                // var kidslocation = new kidslocationModel({
                //     kidsId: kidsId,
                //     parentsId: null,
                //     source: source,
                //     destination: destination,
                //     lon: null,
                //     lat: null,
                //     start: start,
                //     end: end,
                //     polygon: polygon,
                //     status: true,
                //     date: currentDate.toString()
                // }); // make kidslocation data form.
                // kidslocation.save(function (err, data) {});
                kidslocationModel.updateOne({ kidsId: kidsId }, {
                    source: source,
                    destination: destination,
                    start: start,
                    end: end,
                    polygon: polygon,
                    status: true,
                    date: currentDate.toString()
                }, { upsert: true }, function (err, data) { if(err) console.log(err); });
            }
        
            else { // 초기 정보를 넣고 나서 지속적으로 위경도 데이터 업데이트.
                console.log('status is true');
                var lon = req.body['lon'];
                var lat = req.body['lat'];
                console.log(lat);
                console.log(lon);
                kidslocationModel.updateOne({ kidsId: kidsId }, {
                    lat: lat,
                    lon: lon,
                }, { upsert: true }, function (err, data) { if(err) console.log(err); });
            }
        });
    }

    else res.send('no id or key');
}

// /kids/location/end
exports.end = function (req, res) {
    const kidsId = req.body['kidsId'];
    const key = req.body['key'];

    if( kidsId && key ) {
        console.log('status changes false!');

        kidslocationModel.find({ kidsId: kidsId }, (err, kdata) => {
            if( Object.keys(kdata).length === 0 ) res.send('key is wrong');

            kidslocationModel.updateOne({ kidsId: kidsId }, { status: false },
                function (err, data) { if(err) console.log(err); });
        });
    }

    else res.send('no id or key');
}
