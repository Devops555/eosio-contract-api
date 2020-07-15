CREATE OR REPLACE VIEW atomicassets_assets_master AS
    SELECT
        asset_a.contract, asset_a.asset_id, asset_a.owner,

        template_a.readable_name template_readable_name,
        asset_a.readable_name asset_readable_name,
        CASE WHEN template_a.readable_name IS NULL THEN asset_a.readable_name ELSE template_a.readable_name END AS name,

        CASE WHEN template_a.template_id IS NULL THEN true ELSE template_a.transferable END AS is_transferable,
        CASE WHEN template_a.template_id IS NULL THEN true ELSE template_a.burnable END AS is_burnable,

        asset_a.collection_name,
        json_build_object(
            'collection_name', collection_a.collection_name,
            'name', collection_a.readable_name,
            'img', collection_a.data->'img',
            'author', collection_a.author,
            'allow_notify', collection_a.allow_notify,
            'authorized_accounts', collection_a.authorized_accounts,
            'notify_accounts', collection_a.notify_accounts,
            'market_fee', collection_a.market_fee,
            'created_at_block', collection_a.created_at_block,
            'created_at_time', collection_a.created_at_time
        ) collection,

        asset_a.schema_name,
        json_build_object(
            'schema_name', schema_a.schema_name,
            'format', schema_a.format,
            'created_at_block', schema_a.created_at_block,
            'created_at_time', schema_a.created_at_time
        ) "schema",

        asset_a.template_id,
        CASE WHEN template_a.template_id IS NULL THEN null ELSE
        json_build_object(
            'template_id', template_a.template_id,
            'max_supply', template_a.max_supply,
            'is_transferable', template_a.transferable,
            'is_burnable', template_a.burnable,
            'issued_supply', template_a.issued_supply,
            'immutable_data', (SELECT json_object_agg("key", "value") FROM atomicassets_templates_data WHERE contract = asset_a.contract AND template_id = asset_a.template_id),
            'created_at_time', template_a.created_at_time,
            'created_at_block', template_a.created_at_block
        ) END AS "template",

        (SELECT json_object_agg("key", "value") FROM atomicassets_assets_data WHERE contract = asset_a.contract AND asset_id = asset_a.asset_id AND mutable IS true) mutable_data,
        (SELECT json_object_agg("key", "value") FROM atomicassets_assets_data WHERE contract = asset_a.contract AND asset_id = asset_a.asset_id AND mutable IS false) immutable_data,

        ARRAY(
            SELECT DISTINCT ON (backed_b.contract, backed_b.asset_id, backed_b.token_symbol)
                json_build_object(
                    'token_contract', symbols_b.token_contract,
                    'token_symbol', symbols_b.token_symbol,
                    'token_precision', symbols_b.token_precision,
                    'amount', backed_b.amount
                )
            FROM atomicassets_assets_backed_tokens backed_b, atomicassets_tokens symbols_b
            WHERE
                backed_b.contract = symbols_b.contract AND backed_b.token_symbol = symbols_b.token_symbol AND
                backed_b.contract = asset_a.contract AND backed_b.asset_id = asset_a.asset_id
        ) backed_tokens,

        asset_a.burned_at_block, asset_a.burned_at_time, asset_a.updated_at_block,
        asset_a.updated_at_time, asset_a.minted_at_block, asset_a.minted_at_time
    FROM
        atomicassets_assets asset_a
        LEFT JOIN atomicassets_templates template_a ON (
            template_a.contract = asset_a.contract AND template_a.template_id = asset_a.template_id
        )
        JOIN atomicassets_collections collection_a ON (collection_a.contract = asset_a.contract AND collection_a.collection_name = asset_a.collection_name)
        JOIN atomicassets_schemas schema_a ON (schema_a.contract = asset_a.contract AND schema_a.collection_name = asset_a.collection_name AND schema_a.schema_name = asset_a.schema_name)
