part of dart_sunshine.persistence;

/// Makes [Settings] persistence
class SettingsDAO {

    static const String _KEY_LOCATION = "location";
    static const String _KEY_UNITS = "units";
    static const String _KEY_API_KEY = "api_key";

    Future save(final Settings settings) async {
        Validate.notNull(settings);
        Validate.notBlank(settings.location);
        Validate.notBlank(settings.apiKey);

        final Store db = await _db;

        await db.save(settings.location, _KEY_LOCATION);
        await db.save(settings.units.toString(), _KEY_UNITS);
        return db.save(settings.apiKey, _KEY_API_KEY);
    }

    Future<Settings> get settings async {
        final Store db = await _db;
        final String location = await db.getByKey(_KEY_LOCATION);
        final String apikey = await db.getByKey(_KEY_API_KEY);
        final String units = (await db.getByKey(_KEY_UNITS));

        if(location == null || apikey == null || units == null) {
            throw new DBException("Invalid settings!");
        }

        return new Settings(
            location,
            units == Units.METRIC.toString() ? Units.METRIC : Units.IMPERIAL,
            apikey);
    }

    //- private --------------------------------------------------------------------------------------------------------

    Future<Store> get _db async => await Store.open(Table.SETTINGS.db, Table.SETTINGS.name);
}