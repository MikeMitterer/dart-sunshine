part of dart_sunshine.persistance;

/// Identifiziert den Client über eine UUID
class ForecastDAO {

    /// This field stores [_KEY_LAST_UPDATE] the last update date
    static const String _KEY_LAST_UPDATE = "last_update";

    /// Number of Forecasts
    static const String _KEY_NUMBER_OF_FORECASTS = "nr_of_forecasts";

    /// Key for [Forecast] row
    static const String _KEY_FORECAST = "forecast.";

    Future saveLastUpdate(final DateTime date) async {
        Validate.notNull(date);

        final Store db = await _db;

        return db.save((date.microsecondsSinceEpoch).toString(),_KEY_LAST_UPDATE);
    }

    Future<DateTime> get last_update async {
        final Store db = await _db;
        final String timestamp = await db.getByKey(_KEY_LAST_UPDATE);

        if(timestamp == null || timestamp.isEmpty) {
            throw new DBException("Last-Update is not available - update your DB first!");
        }
        return new DateTime.fromMicrosecondsSinceEpoch(int.parse(timestamp));
    }


    Future<List<Forecast>> get forecasts async {
        final Store db = await _db;
        final List<Forecast> forecasts = new List<Forecast>();

        final int nrOfItems = int.parse(await db.getByKey(_KEY_NUMBER_OF_FORECASTS));
        await Future.forEach(new List.generate(nrOfItems, (final int index) => index), (final int index) async {
            final String json = await db.getByKey("${_KEY_FORECAST}$index");
            forecasts.add(new Forecast.fromJson(json));
        });

        return forecasts;
    }

    /// Saves all the [Forecast]s 
    Future saveForecast(final List<Forecast> forecasts) async {
        Validate.notNull(forecasts);

        final Store db = await _db;
        await db.save(forecasts.length.toString(), _KEY_NUMBER_OF_FORECASTS);

        int index = 0;
        await Future.forEach(forecasts, (final Forecast forecast) async {
            await db.save(forecast.toString(), "${_KEY_FORECAST}$index");
            index++;
        });
    }

    //- private --------------------------------------------------------------------------------------------------------

    Future<Store> get _db async => await Store.open(Table.FORECAST.db, Table.FORECAST.name);
}