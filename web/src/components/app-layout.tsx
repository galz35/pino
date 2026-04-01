import apiClient from '@/services/api-client';
import React, { useEffect, useMemo, useState } from 'react';
import { Link, useLocation, useParams } from 'react-router-dom';
import { useAuth } from '@/contexts/auth-context';
import { AppHeader } from '@/components/app-header';
import { cn } from '@/lib/utils';
import {
  LayoutDashboard, Store, Briefcase, Users, WalletCards, RefreshCw,
  FileText, Map, MapPin, Settings, LifeBuoy, Package, History, Wrench,
  ShoppingCart, ClipboardCheck, AreaChart, UsersRound, Truck, HandCoins,
  ShieldCheck, SendToBack, Route, DollarSign, ListOrdered, PackagePlus,
} from 'lucide-react';

export interface Notification {
  id: string;
  title: string;
  description: string;
  href: string;
  userId: string;
  read: boolean;
}

interface StoreSettings {
  exchangeRate?: number;
  enableDispatcherMode?: boolean;
  enableSalesManagerMode?: boolean;
  enableSupplierManagement?: boolean;
}

const translations = {
  es: {
    dashboard: 'Panel',
    stores: 'Tiendas',
    users: 'Usuarios',
    licenses: 'Licencias',
    monitor: 'Monitor',
    help: 'Ayuda',
    billing: 'Facturación',
    cashRegister: 'Caja',
    products: 'Productos',
    movements: 'Movimientos',
    adjustments: 'Ajustes',
    settings: 'Configuración',
    reports: 'Reportes',
    vendors: 'Vendedores',
    assignInventory: 'Asignar Inventario',
    myRoute: 'Mi Ruta',
    addClient: 'Clientes',
    sales: 'Ventas',
    dispatcher: 'Despacho',
    pendingOrders: 'Comandas',
    deliveryRoute: 'Ruta de Entrega',
    registerOrder: 'Registrar Pedido',
    assignRoute: 'Asignar Ruta',
    suppliers: 'Proveedores',
    quickSale: 'Venta Rápida',
    authorizations: 'Autorizaciones',
    accountsReceivable: 'Cuentas por Cobrar',
    routes: 'Rutas',
  },
  en: {
    dashboard: 'Dashboard',
    stores: 'Stores',
    users: 'Users',
    licenses: 'Licenses',
    monitor: 'Monitor',
    help: 'Help',
    billing: 'Billing',
    cashRegister: 'Cash Register',
    products: 'Products',
    movements: 'Movements',
    adjustments: 'Adjustments',
    settings: 'Settings',
    reports: 'Reports',
    vendors: 'Vendors',
    assignInventory: 'Assign Inventory',
    myRoute: 'My Route',
    addClient: 'Add Client',
    sales: 'Sales',
    dispatcher: 'Dispatcher',
    pendingOrders: 'Orders',
    deliveryRoute: 'Delivery Route',
    registerOrder: 'Register Order',
    assignRoute: 'Assign Route',
    suppliers: 'Suppliers',
    quickSale: 'Quick Sale',
    authorizations: 'Authorizations',
    accountsReceivable: 'Accounts Receivable',
    routes: 'Routes',
  }
};

const getMasterAdminNav = (lang: 'es' | 'en') => [
  { name: translations[lang].dashboard, href: '/master-admin/dashboard', icon: LayoutDashboard },
  { name: translations[lang].stores, href: '/master-admin/stores', icon: Store },
  { name: 'Cadenas', href: '/master-admin/chains', icon: Briefcase },
  { name: translations[lang].users, href: '/master-admin/users', icon: Users },
  { name: 'Zonas Globales', href: '/master-admin/config/zones', icon: Map },
  { name: 'Sub-Zonas (Barrios)', href: '/master-admin/config/sub-zones', icon: MapPin },
  { name: translations[lang].licenses, href: '/master-admin/licenses', icon: WalletCards },
  { name: 'Monitor Sync', href: '/master-admin/sync-monitor', icon: RefreshCw },
  { name: translations[lang].monitor, href: '/master-admin/monitor', icon: FileText },
  { name: 'Configuración', href: '/master-admin/config', icon: Settings },
  { name: translations[lang].help, href: '/master-admin/help', icon: LifeBuoy },
];

const getStoreAdminNav = (storeId: string, lang: 'es' | 'en', settings: StoreSettings) => {
  const nav = [
    ...(settings.enableDispatcherMode ? [{
      name: translations[lang].pendingOrders,
      href: `/store/${storeId}/pending-orders`,
      icon: ClipboardCheck,
    }] : []),
    {
      name: translations[lang].cashRegister,
      href: `/store/${storeId}/cash-register`,
      icon: WalletCards,
    },
    {
      name: translations[lang].dashboard,
      href: `/store/${storeId}/dashboard`,
      icon: LayoutDashboard,
    },
    { name: translations[lang].products, href: `/store/${storeId}/products`, icon: Package },
    { name: translations[lang].movements, href: `/store/${storeId}/inventory/movements`, icon: History },
    ...(settings.enableSupplierManagement ? [{
      name: translations[lang].suppliers,
      href: `/store/${storeId}/suppliers`,
      icon: Briefcase,
    }] : []),
    { name: translations[lang].reports, href: `/store/${storeId}/reports`, icon: AreaChart },
    { name: translations[lang].users, href: `/store/${storeId}/users`, icon: Users },
    { name: 'Zonas y Barrios', href: `/store/${storeId}/vendors/zones`, icon: Map },
    ...(settings.enableSalesManagerMode ? [
      { name: translations[lang].vendors, href: `/store/${storeId}/vendors`, icon: UsersRound },
      { name: translations[lang].assignRoute, href: `/store/${storeId}/vendors/assign-route`, icon: Route },
      { name: translations[lang].routes, href: `/store/${storeId}/vendors/routes`, icon: MapPin },
      { name: translations[lang].addClient, href: `/store/${storeId}/vendors/clients`, icon: Users },
      { name: translations[lang].assignInventory, href: `/store/${storeId}/vendors/inventory`, icon: Truck },
      { name: translations[lang].accountsReceivable, href: `/store/${storeId}/vendors/collections`, icon: HandCoins },
    ] : []),
    {
      name: translations[lang].authorizations,
      href: `/store/${storeId}/authorizations`,
      icon: ShieldCheck,
    },
    { name: translations[lang].settings, href: `/store/${storeId}/settings`, icon: Settings },
    { name: translations[lang].help, href: `/store/${storeId}/help`, icon: LifeBuoy },
  ];
  return nav;
};

const getBodegueroNav = (storeId: string, lang: 'es' | 'en') => [
  { name: translations[lang].products, href: `/store/${storeId}/products`, icon: Package },
  { name: translations[lang].movements, href: `/store/${storeId}/inventory/movements`, icon: History },
  { name: translations[lang].adjustments, href: `/store/${storeId}/inventory/adjustments`, icon: Wrench },
  { name: translations[lang].suppliers, href: `/store/${storeId}/suppliers`, icon: Briefcase },
  { name: translations[lang].help, href: `/store/${storeId}/help`, icon: LifeBuoy },
];

const getCashierNav = (storeId: string, lang: 'es' | 'en', settings: StoreSettings) => {
  const nav = [
    { name: translations[lang].billing, href: `/`, icon: ShoppingCart },
    ...(settings.enableDispatcherMode ? [{
      name: translations[lang].pendingOrders,
      href: `/store/${storeId}/pending-orders`,
      icon: ClipboardCheck,
    }] : []),
    { name: translations[lang].cashRegister, href: `/store/${storeId}/cash-register`, icon: WalletCards },
    { name: translations[lang].help, href: `/store/${storeId}/help`, icon: LifeBuoy },
  ];
  return nav;
};

const getDespachoNav = (storeId: string, lang: 'es' | 'en') => [
  { name: translations[lang].dispatcher, href: `/store/${storeId}/dispatcher`, icon: SendToBack },
  { name: translations[lang].help, href: `/store/${storeId}/help`, icon: LifeBuoy },
];

const getRuteroNav = (storeId: string, lang: 'es' | 'en', settings: StoreSettings) => {
  if (!settings.enableSalesManagerMode) return [{ name: translations[lang].help, href: `/store/${storeId}/help`, icon: LifeBuoy }];
  return [
    { name: translations[lang].deliveryRoute, href: `/store/${storeId}/delivery-route`, icon: Route },
    { name: translations[lang].help, href: `/store/${storeId}/help`, icon: LifeBuoy },
  ];
};

const getVendedorAmbulanteNav = (storeId: string, lang: 'es' | 'en') => [
  { name: translations[lang].quickSale, href: `/store/${storeId}/vendors/quick-sale`, icon: DollarSign },
  { name: translations[lang].addClient, href: `/store/${storeId}/vendors/clients`, icon: Users },
  { name: translations[lang].sales, href: `/store/${storeId}/vendors/sales`, icon: ListOrdered },
  { name: translations[lang].help, href: `/store/${storeId}/help`, icon: LifeBuoy },
];

const getGestorVentasNav = (storeId: string, lang: 'es' | 'en') => [
  { name: translations[lang].myRoute, href: `/store/${storeId}/vendors/dashboard`, icon: Route },
  { name: translations[lang].assignRoute, href: `/store/${storeId}/vendors/assign-route`, icon: ClipboardCheck },
  { name: translations[lang].routes, href: `/store/${storeId}/vendors/routes`, icon: MapPin },
  { name: translations[lang].registerOrder, href: `/store/${storeId}/vendors/sales`, icon: PackagePlus },
  { name: translations[lang].addClient, href: `/store/${storeId}/vendors/clients`, icon: Users },
  { name: 'Gestionar Zonas', href: `/store/${storeId}/vendors/zones`, icon: Map },
  { name: translations[lang].sales, href: `/store/${storeId}/vendors/sales`, icon: ListOrdered },
  { name: translations[lang].help, href: `/store/${storeId}/help`, icon: LifeBuoy },
];


function MainNav({
  navItems,
  onLinkClick,
}: {
  navItems: { name: string; href: string; icon: React.ElementType }[];
  onLinkClick?: () => void;
}) {
  const location = useLocation();
  const pathname = location.pathname;

  const handleLinkClick = () => {
    if (onLinkClick) {
      onLinkClick();
    }
  };

  return (
    <>
      {navItems.map((item) => {
        const Icon = item.icon;
        const isActive = pathname.startsWith(item.href) && item.href !== '/' || (pathname === '/' && item.href === '/');

        return (
          <Link
            key={item.name}
            to={item.href}
            onClick={handleLinkClick}
            className={cn(
              'flex items-center gap-3 rounded-lg px-3 py-2 text-muted-foreground transition-all hover:text-primary',
              isActive && 'bg-muted text-primary'
            )}
          >
            <Icon className="h-4 w-4" />
            {item.name}
          </Link>
        );
      })}
    </>
  );
}


export default function AppLayout({ children }: { children: React.ReactNode }) {
  const { storeId } = useParams();
  const { user } = useAuth();
  const [language, setLanguage] = useState<'es' | 'en'>('es');
  const [storeSettings, setStoreSettings] = useState<StoreSettings>({
    enableDispatcherMode: true,
    enableSalesManagerMode: true,
    enableSupplierManagement: true,
  });
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const location = useLocation();
  const pathname = location.pathname;

  useEffect(() => {
    if (!storeId) return;
    const fetchStoreSettings = async () => {
      try {
        const res = await apiClient.get(`/stores/${storeId}`);
        if (res.data && res.data.settings) {
          setStoreSettings(res.data.settings);
        }
      } catch (error) {
         // ignore
      }
    };
    fetchStoreSettings();
  }, [storeId]);

  const handleLanguageChange = (lang: string) => {
    setLanguage(lang as 'es' | 'en');
  };

  const handleNotificationClick = (notificationId: string) => {
    setNotifications((prev: Notification[]) =>
      prev.map((n: Notification) => (n.id === notificationId ? { ...n, read: true } : n))
    );
  };

  const navItems = useMemo(() => {
    const roleId = user?.role?.toLowerCase() || '';
    switch (roleId) {
      case 'master-admin':
      case 'owner':
        return getMasterAdminNav(language);
      case 'store-admin':
      case 'admin':
        return getStoreAdminNav(storeId || '', language, storeSettings);
      case 'inventory':
      case 'bodeguero':
      case 'ayudante de bodega':
        return getBodegueroNav(storeId || '', language);
      case 'cashier':
      case 'cajero':
        return getCashierNav(storeId || '', language, storeSettings);
      case 'dispatcher':
      case 'despacho':
        return getDespachoNav(storeId || '', language);
      case 'rutero':
        return getRuteroNav(storeId || '', language, storeSettings);
      case 'vendedor ambulante':
        return getVendedorAmbulanteNav(storeId || '', language);
      case 'gestor de ventas':
        return getGestorVentasNav(storeId || '', language);
      default:
        // Default to store admin nav for robust fallback if storeId exists
        return storeId ? getStoreAdminNav(storeId, language, storeSettings) : [];
    }
  }, [user, language, storeId, storeSettings]);

  const nav = <MainNav navItems={navItems} onLinkClick={() => {}} />;

  if (pathname === '/' && user?.role !== 'master-admin' && user?.role !== 'owner') {
    return <>{children}</>;
  }

  return (
    <div className="grid min-h-screen w-full md:grid-cols-[220px_1fr] lg:grid-cols-[280px_1fr]">
      <div className="hidden border-r bg-muted/40 md:block">
        <div className="flex h-full max-h-screen flex-col gap-2">
          <div className="flex h-16 items-center border-b px-4 lg:h-[60px] lg:px-6">
            <Link to={user?.role === 'master-admin' ? '/master-admin/dashboard' : (storeId ? `/store/${storeId}/dashboard` : '/')} className="flex items-center gap-2 font-semibold">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                className="h-6 w-6 text-primary"
              >
                <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"></path>
              </svg>
              <span>MultiTienda</span>
            </Link>
          </div>

          <div className="flex-1 overflow-y-auto">
            <nav className="grid items-start px-2 text-sm font-medium lg:px-4">
              {nav}
            </nav>
          </div>
        </div>
      </div>
      <div className="flex flex-col">
        <AppHeader
          navItems={navItems}
          language={language}
          onLanguageChange={handleLanguageChange}
          exchangeRate={storeSettings.exchangeRate}
          notifications={notifications}
          onNotificationClick={handleNotificationClick}
        />
        <main className="flex flex-1 flex-col gap-4 p-4 lg:gap-6 lg:p-6 bg-background overflow-x-hidden">
          {children}
        </main>

        <footer className="flex items-center justify-between p-4 text-xs text-muted-foreground border-t">
          <span>© {new Date().getFullYear()} World Wide All in One Programing. Todos los derechos reservados.</span>
        </footer>
      </div>
    </div>
  );
}
