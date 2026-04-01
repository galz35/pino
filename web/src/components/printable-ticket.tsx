import apiClient from '@/services/api-client';

import { useEffect, useState } from "react";
import { format } from 'date-fns';
import { es } from 'date-fns/locale';

interface Movement {
    id: string;
    timestamp: any;
    productDescription: string;
    movement: string;
    type: string;
    had: number;
    quantity: number;
    has: number;
}

interface Settings {
  headerLine1?: string;
  headerLine2?: string;
  headerLine3?: string;
  headerLine4?: string;
  footerLine1?: string;
  footerLine2?: string;
  fontFamily?: string;
  fontSize?: number;
  columns?: number;
}

interface PrintableTicketProps {
    storeId: string;
    movements: Movement[];
    date?: Date;
}

async function fetchStoreSettings(storeId: string): Promise<Settings | null> {
    try {
        const res = await apiClient.get(`/stores/${storeId}`);
        if (res.data && res.data.settings) {
            return res.data.settings;
        }
        return null;
    } catch (error) {
        console.error("Failed to fetch store settings:", error);
        return null;
    }
}

function parseTimestamp(ts: any): Date {
    if (!ts) return new Date();
    if (ts instanceof Date) return ts;
    if (typeof ts === 'string') return new Date(ts);
    if (ts.toDate) return ts.toDate();
    return new Date();
}

export async function generatePlainTextTicket(storeId: string, movements: Movement[], date?: Date): Promise<string> {
    const settings = await fetchStoreSettings(storeId);
    const columns = settings?.columns || 32;

    const center = (text: string) => text.padStart((columns + text.length) / 2, ' ').padEnd(columns, ' ');
    const line = '-'.repeat(columns);

    let output = '';
    
    // Header
    if (settings?.headerLine1) output += center(settings.headerLine1) + '\n';
    if (settings?.headerLine2) output += center(settings.headerLine2) + '\n';
    if (settings?.headerLine3) output += center(settings.headerLine3) + '\n';
    if (settings?.headerLine4) output += center(settings.headerLine4) + '\n';
    output += '\n';

    // Info
    output += line + '\n';
    output += 'Reporte de Movimientos'.padEnd(columns, ' ') + '\n';
    const dateStr = date ? format(date, 'PPP', { locale: es }) : 'N/A';
    output += `Fecha: ${dateStr}`.padEnd(columns, ' ') + '\n';
    output += line + '\n';

    // Items Header
    output += 'HORA'.padEnd(8) + 'PRODUCTO'.padEnd(columns - 16) + 'CANT.'.padStart(8) + '\n';
    output += line + '\n';

    // Items
    for (const item of movements) {
        const dateObj = parseTimestamp(item.timestamp);
        const time = item.timestamp ? format(dateObj, 'p', { locale: es }) : '';
        const desc = item.productDescription;
        const qty = item.quantity.toFixed(2);
        
        output += time.padEnd(8) + desc.substring(0, columns - 17).padEnd(columns - 16) + qty.padStart(8) + '\n';
    }
    output += line + '\n';

    // Footer Totals
    const totalMovements = `No. de Movs: ${movements.length}`;
    const totalItems = `Total de Pzas: ${movements.reduce((acc, mov) => acc + Math.abs(mov.quantity), 0).toFixed(2)}`;
    output += totalMovements.padStart(columns, ' ') + '\n';
    output += totalItems.padStart(columns, ' ') + '\n\n';

    // Footer Text
    if (settings?.footerLine1) output += center(settings.footerLine1) + '\n';
    if (settings?.footerLine2) output += center(settings.footerLine2) + '\n';

    return output;
}

export function PrintableTicket({ storeId, movements, date }: PrintableTicketProps) {
  const [settings, setSettings] = useState<Settings | null>(null);

  useEffect(() => {
    async function loadSettings() {
      const fetchedSettings = await fetchStoreSettings(storeId);
      setSettings(fetchedSettings);
    }
    loadSettings();
  }, [storeId]);
  
  const totalItems = movements.reduce((acc, mov) => acc + Math.abs(mov.quantity), 0);
  const dateStr = date ? format(date, 'PPP', { locale: es }) : 'N/A';

  return (
    <div 
        id="printable-content" 
        className="hidden print:block font-mono text-black bg-white p-2"
        style={{ fontFamily: settings?.fontFamily || 'monospace', fontSize: `${settings?.fontSize || 10}pt` }}
    >
        <div className="text-center space-y-1 mb-4">
            {settings?.headerLine1 && <p>{settings.headerLine1}</p>}
            {settings?.headerLine2 && <p>{settings.headerLine2}</p>}
            {settings?.headerLine3 && <p>{settings.headerLine3}</p>}
            {settings?.headerLine4 && <p>{settings.headerLine4}</p>}
        </div>

        <div className="border-t border-b border-dashed border-gray-600 py-1">
            <p>Reporte de Movimientos</p>
            <p>Fecha: {dateStr}</p>
        </div>

        <div className="my-2">
          <div className="grid grid-cols-12 gap-2 font-bold">
            <span className="col-span-2">HORA</span>
            <span className="col-span-7">PRODUCTO</span>
            <span className="col-span-3 text-right">CANT.</span>
          </div>
          <div className="border-t border-b border-dashed border-gray-600 my-1 py-1 space-y-1">
            {movements.map((item, idx) => {
                const dateObj = parseTimestamp(item.timestamp);
                return (
                    <div key={item.id || idx.toString()} className="grid grid-cols-12 gap-2">
                        <span className="col-span-2">{item.timestamp ? format(dateObj, 'p', { locale: es }) : ''}</span>
                        <span className="col-span-7">{item.productDescription}</span>
                        <span className="col-span-3 text-right">{item.quantity.toFixed(2)}</span>
                    </div>
                );
            })}
          </div>
        </div>
        
        <div className="flex justify-end mt-2">
          <div className="w-1/2">
            <div className="flex justify-between">
              <span>No. de Movs:</span>
              <span>{movements.length}</span>
            </div>
             <div className="flex justify-between">
              <span>Total de Pzas:</span>
              <span>{totalItems.toFixed(2)}</span>
            </div>
          </div>
        </div>

        <div className="text-center mt-4 space-y-1">
            {settings?.footerLine1 && <p>{settings.footerLine1}</p>}
            {settings?.footerLine2 && <p>{settings.footerLine2}</p>}
        </div>
    </div>
  );
}
