class DataSourceBase {
    cache := ""
    useCache := false
    maxCacheAge := 86400

    __New(cache := "") {
        if (cache != "") {
            InvalidParameterException.CheckTypes("DataSourceBase", "cache", cache, "CacheBase")
            this.useCache := true
            this.cache := cache
        }
    }

    ItemExists(path) {
        return this.useCache ? this.cache.ItemExists(path) : false
    }

    ReadItem(path) {
        if (this.ItemNeedsRetrieval(path)) {
            this.RetrieveItem(path)
        }

        return this.useCache ? this.cache.ReadItem(path) : ""
    }

    ItemNeedsRetrieval(path) {
        return (!this.useCache || this.cache.ItemNeedsUpdate(path))
    }

    RetrieveItem(path) {
        return ""
    }

    CopyItem(path, destination) {
        if (this.ItemNeedsRetrieval(path)) {
            this.RetrieveItem(path)
        }

        return this.useCache ? this.cache.CopyItem(path, destination) : destination
    }

    GetRemoteLocation(path) {
        
    }

    ReadListing(path) {
        listingInstance := DSListing.new(path, this)

        listingItems := Map()

        if (listingInstance.Exists()) {
            listing := listingInstance.Read()
            listingItems := listing["items"]
        }

        return listingItems
    }

    ReadJson(key, path := "") {
        dsItem := DSJson.new(key, path, this)
        return dsItem.Read()
    }
}