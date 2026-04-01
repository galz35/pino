export interface SystemConfig {
    financialMap: {
        defaultCreditDays: number;
        currencyExchangeRate: number;
    };
    catalogRules: {
        defaultPackagingType: 'BULTO' | 'UNIDAD';
        defaultUnitsPerBulto: number;
    };
}

export const DEFAULT_CONFIG: SystemConfig = {
    financialMap: {
        defaultCreditDays: 8,
        currencyExchangeRate: 1.0,
    },
    catalogRules: {
        defaultPackagingType: 'UNIDAD',
        defaultUnitsPerBulto: 1,
    }
};
