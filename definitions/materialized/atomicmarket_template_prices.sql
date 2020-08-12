CREATE MATERIALIZED VIEW atomicmarket_template_prices AS
    SELECT * FROM atomicmarket_template_prices_master;

CREATE UNIQUE INDEX atomicmarket_template_prices_pkey ON atomicmarket_template_prices (market_contract, assets_contract, collection_name, template_id, symbol);

CREATE INDEX atomicmarket_template_prices_market_contract ON atomicmarket_template_prices USING btree (market_contract);
CREATE INDEX atomicmarket_template_prices_assets_contract ON atomicmarket_template_prices USING btree (assets_contract);
CREATE INDEX atomicmarket_template_prices_collection_name ON atomicmarket_template_prices USING btree (collection_name);
CREATE INDEX atomicmarket_template_prices_template_id ON atomicmarket_template_prices USING btree (template_id);
CREATE INDEX atomicmarket_template_prices_symbol ON atomicmarket_template_prices USING btree (symbol);
CREATE INDEX atomicmarket_template_prices_median ON atomicmarket_template_prices USING btree (median);
CREATE INDEX atomicmarket_template_prices_average ON atomicmarket_template_prices USING btree (average);
CREATE INDEX atomicmarket_template_prices_min ON atomicmarket_template_prices USING btree ("min");
CREATE INDEX atomicmarket_template_prices_max ON atomicmarket_template_prices USING btree ("max");
CREATE INDEX atomicmarket_template_prices_sales ON atomicmarket_template_prices USING btree (sales);

