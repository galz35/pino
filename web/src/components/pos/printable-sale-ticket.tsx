

import { db } from "@/lib/firebase";
import { doc, getDoc, type Timestamp } from "firebase/firestore";
import { useEffect, useState, forwardRef } from "react";
import { format } from 'date-fns';
import { es } from 'date-fns/locale';

interface SaleItem {
  id: string;
  description: string;
  quantity: number;
  salePrice: number;
  costPrice?: number;
}

export interface Sale {
  id: string;
  storeId: string;
  shiftId: string;
  cashierId: string;
  cashierName: string;
  clientId: string;
  clientName: string;
  items: SaleItem[];
  subtotal: number;
  tax: number;
  total: number;
  paymentMethod: string;
  paymentCurrency: 'NIO' | 'USD';
  amountReceived: number;
  change: number;
  ticketNumber?: string;
  createdAt: Date | Timestamp;
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
  sale: Sale | null;
}

async function fetchStoreSettings(storeId: string): Promise<Settings | null> {
  try {
    const storeDocRef = doc(db, 'stores', storeId);
    const storeDoc = await getDoc(storeDocRef);
    if (storeDoc.exists() && storeDoc.data().settings) {
      return storeDoc.data().settings;
    }
    return null;
  } catch (error) {
    console.error("Failed to fetch store settings:", error);
    return null;
  }
}

export const PrintableSaleTicket = forwardRef<HTMLDivElement, PrintableTicketProps>(({ storeId, sale }, ref) => {
  const [settings, setSettings] = useState<Settings | null>(null);

  useEffect(() => {
    async function loadSettings() {
      const fetchedSettings = await fetchStoreSettings(storeId);
      setSettings(fetchedSettings);
    }
    loadSettings();
  }, [storeId]);

  if (!sale) return null;

  const saleDate = sale.createdAt instanceof Date ? sale.createdAt : sale.createdAt.toDate();

  return (
    <div
      ref={ref}
      id="printable-content"
      style={{ fontFamily: settings?.fontFamily || 'monospace', fontSize: `${settings?.fontSize || 10}pt`, color: 'black', background: 'white' }}
    >
      <div style={{ width: `302px`, margin: '0 auto', padding: '10px' }}>
        <div className="text-center space-y-1 mb-4">
          {settings?.headerLine1 && <p>{settings.headerLine1}</p>}
          {settings?.headerLine2 && <p>{settings.headerLine2}</p>}
          {settings?.headerLine3 && <p>{settings.headerLine3}</p>}
          {settings?.headerLine4 && <p>{settings.headerLine4}</p>}
        </div>

        <div className="border-t border-b border-dashed border-gray-600 py-1 text-xs">
          <div className="flex justify-between">
            <span>Fecha: {format(saleDate, 'P', { locale: es })}</span>
            <span>Hora: {format(saleDate, 'p', { locale: es })}</span>
          </div>
          <div className="flex justify-between">
            <span>Cajero: {sale.cashierName}</span>
            <span>Ticket: {sale.ticketNumber || sale.id.slice(-6)}</span>
          </div>
          <div className="flex justify-between">
            <span>Cliente: {sale.clientName}</span>
          </div>
        </div>

        <div className="my-2 text-xs">
          <div className="flex justify-between font-bold">
            <span className="w-1/6 text-left">Cant</span>
            <span className="w-3/6 text-left">Producto</span>
            <span className="w-2/6 text-right">Importe</span>
          </div>
          <div className="border-t border-b border-dashed border-gray-600 my-1 py-1 space-y-1">
            {sale.items.map(item => (
              <div key={item.id} className="flex justify-between">
                <span className="w-1/6 text-left">{item.quantity}</span>
                <span className="w-3/6 text-left">{item.description}</span>
                <span className="w-2/6 text-right">C$ {(item.quantity * item.salePrice).toFixed(2)}</span>
              </div>
            ))}
          </div>
        </div>

        <div className="flex justify-end mt-2 text-xs">
          <div className="w-1/2">
            <div className="flex justify-between">
              <span>Subtotal:</span>
              <span>C$ {sale.subtotal.toFixed(2)}</span>
            </div>
            {sale.tax > 0 && (
              <div className="flex justify-between">
                <span>IVA (15%):</span>
                <span>C$ {sale.tax.toFixed(2)}</span>
              </div>
            )}
            <div className="flex justify-between font-bold text-sm mt-1">
              <span>TOTAL:</span>
              <span>C$ {sale.total.toFixed(2)}</span>
            </div>
            <div className="flex justify-between">
              <span>Recibido:</span>
              <span>C$ {sale.amountReceived.toFixed(2)}</span>
            </div>
            <div className="flex justify-between">
              <span>Cambio:</span>
              <span>C$ {sale.change.toFixed(2)}</span>
            </div>
          </div>
        </div>

        <div className="text-center mt-4 space-y-1 text-xs">
          {settings?.footerLine1 && <p>{settings.footerLine1}</p>}
          {settings?.footerLine2 && <p>{settings.footerLine2}</p>}
        </div>
      </div>
    </div>
  );
});

PrintableSaleTicket.displayName = 'PrintableSaleTicket';
