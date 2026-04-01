export interface Zone {
    id?: string;
    name: string;
    code?: string;
    isActive: boolean;
    createdAt?: any; // Firestore Timestamp
}

export interface SubZone {
    id?: string;
    name: string;
    zoneId: string;
    routeDays: number[]; // 1=Monday, 7=Sunday
    isActive: boolean;
    createdAt?: any;
}
