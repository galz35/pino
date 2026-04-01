import apiClient from '@/services/api-client';

import { StoreAdminDashboardMetrics } from "@/components/dashboard/store-admin-dashboard-metrics";
import { useParams } from "react-router-dom";
import { useEffect, useState } from "react";

export default function DashboardPage() {
  const [storeName, setStoreName] = useState('');
  const [loading, setLoading] = useState(true);
  const params = useParams();
  const storeId = params.storeId as string;
  
  useEffect(() => {
    if (!storeId) return;
    
    const fetchStoreName = async () => {
      try {
        const res = await apiClient.get(`/stores/${storeId}`);
        if (res.data && res.data.name) {
          setStoreName(res.data.name);
        } else {
          setStoreName('Tienda Desconocida');
        }
      } catch (error) {
        console.error("Error fetching store name: ", error);
        setStoreName('Tienda');
      } finally {
          setLoading(false);
      }
    };
    
    fetchStoreName();

  }, [storeId]);

  if (loading) {
    return <div>Cargando...</div>
  }

  return (
    <div>
      <h1 className="text-2xl font-bold tracking-tight mb-4">Panel de Tienda: {storeName}</h1>
      <p className="text-muted-foreground mb-6">
        Aquí están las métricas más importantes para administrar tu tienda.
      </p>
      <StoreAdminDashboardMetrics storeId={storeId} />
    </div>
  )
}
