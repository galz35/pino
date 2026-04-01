import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import React, { Suspense, lazy } from 'react';
import { ThemeProvider } from '@/components/theme-provider';
import { AuthProvider, useAuth } from '@/contexts/auth-context';
import { PosProvider } from '@/contexts/pos-context';
import { GlobalAlertProvider } from '@/components/global-alert-provider';
import { Toaster } from '@/components/ui/toaster';
import ErrorBoundary from '@/components/error-boundary';
import AppLayout from '@/components/app-layout';

// LAZY LOADED PAGES
const LoginPage = lazy(() => import('@/pages/login-page'));
const PosPage = lazy(() => import('@/pages/pos-page'));
const DashboardPage = lazy(() => import('@/pages/store-admin/dashboard/dashboard-page'));
const BillingPage = lazy(() => import('@/pages/store-admin/billing/billing-page'));
const ProductsPage = lazy(() => import('@/pages/store-admin/products/products-page'));
const AddProductPage = lazy(() => import('@/pages/store-admin/products/add-product-page'));
const DepartmentsPage = lazy(() => import('@/pages/store-admin/products/departments-page'));
const SubDepartmentsPage = lazy(() => import('@/pages/store-admin/products/sub-departments-page'));
const ReportsPage = lazy(() => import('@/pages/store-admin/reports/reports-page'));
const UsersPage = lazy(() => import('@/pages/store-admin/users/users-page'));
const AddUserPage = lazy(() => import('@/pages/store-admin/users/add-user-page'));
const EditUserPage = lazy(() => import('@/pages/store-admin/users/edit-user-page'));
const SettingsPage = lazy(() => import('@/pages/store-admin/settings/settings-page'));
const InventoryMovementsPage = lazy(() => import('@/pages/store-admin/inventory/inventory-movements-page'));
const InventoryAdjustmentsPage = lazy(() => import('@/pages/store-admin/inventory/inventory-adjustments-page'));
const SuppliersPage = lazy(() => import('@/pages/store-admin/suppliers/suppliers-page'));
const AddSupplierPage = lazy(() => import('@/pages/store-admin/suppliers/add-supplier-page'));
const EditSupplierPage = lazy(() => import('@/pages/store-admin/suppliers/edit-supplier-page'));
const CashRegisterPage = lazy(() => import('@/pages/store-admin/cash-register/cash-register-page'));
const AuthorizationsPage = lazy(() => import('@/pages/store-admin/authorizations/authorizations-page'));
const PendingOrdersPage = lazy(() => import('@/pages/store-admin/pending-orders/pending-orders-page'));
const DispatcherPage = lazy(() => import('@/pages/store-admin/dispatcher/dispatcher-page'));
const ControlTowerPage = lazy(() => import('@/pages/store-admin/control-tower/control-tower-page'));
const DeliveryRoutePage = lazy(() => import('@/pages/store-admin/delivery-route/delivery-route-page'));
const HelpPage = lazy(() => import('@/pages/store-admin/help/help-page'));
const VendorsPage = lazy(() => import('@/pages/store-admin/vendors/vendors-page'));
const VendorDashboardPage = lazy(() => import('@/pages/store-admin/vendors/vendor-dashboard-page'));
const VendorZonesPage = lazy(() => import('@/pages/store-admin/vendors/vendor-zones-page'));
const VendorClientsPage = lazy(() => import('@/pages/store-admin/vendors/vendor-clients-page'));
const VendorCollectionsPage = lazy(() => import('@/pages/store-admin/vendors/vendor-collections-page'));
const VendorInventoryPage = lazy(() => import('@/pages/store-admin/vendors/vendor-inventory-page'));
const AddVendorPage = lazy(() => import('@/pages/store-admin/vendors/add-vendor-page'));
const VendorQuickSalePage = lazy(() => import('@/pages/store-admin/vendors/vendor-quick-sale-page'));
const VendorSalesPage = lazy(() => import('@/pages/store-admin/vendors/vendor-sales-page'));
const AssignRoutePage = lazy(() => import('@/pages/store-admin/vendors/assign-route-page'));
const VendorRoutesPage = lazy(() => import('@/pages/store-admin/vendors/vendor-routes-page'));
const MasterDashboardPage = lazy(() => import('@/pages/master-admin/master-dashboard-page'));
const MasterStoresPage = lazy(() => import('@/pages/master-admin/master-stores-page'));
const MasterChainsPage = lazy(() => import('@/pages/master-admin/master-chains-page'));
const AddChainPage = lazy(() => import('@/pages/master-admin/add-chain-page'));
const MasterUsersPage = lazy(() => import('@/pages/master-admin/master-users-page'));
const MasterLicensesPage = lazy(() => import('@/pages/master-admin/master-licenses-page'));
const MasterMonitorPage = lazy(() => import('@/pages/master-admin/master-monitor-page'));
const AddStorePage = lazy(() => import('@/pages/master-admin/add-store-page'));
const EditStorePage = lazy(() => import('@/pages/master-admin/edit-store-page'));
const MasterConfigPage = lazy(() => import('@/pages/master-admin/master-config-page'));
const MasterZonesPage = lazy(() => import('@/pages/master-admin/master-zones-page'));
const MasterSubZonesPage = lazy(() => import('@/pages/master-admin/master-sub-zones-page'));
const MasterSyncMonitorPage = lazy(() => import('@/pages/master-admin/master-sync-monitor-page'));
const MasterHelpPage = lazy(() => import('@/pages/master-admin/master-help-page'));

const LoadingFallback = () => (
  <div className="flex h-screen items-center justify-center bg-background">
    <div className="text-center">
      <div className="animate-spin h-12 w-12 border-4 border-primary border-t-transparent rounded-full mx-auto mb-4"></div>
      <p className="font-black uppercase tracking-widest text-muted-foreground text-xs">Acelerando sistema...</p>
    </div>
  </div>
);

const ProtectedRoute = ({ children }: { children: React.ReactNode }) => {
  const { isAuthenticated, loading } = useAuth();
  
  if (loading) return <LoadingFallback />;
  
  if (!isAuthenticated) return <Navigate to="/login" replace />;
  
  return <AppLayout>{children}</AppLayout>;
};

function App() {
  return (
    <ThemeProvider attribute="class" defaultTheme="light" enableSystem={false}>
      <BrowserRouter>
        <AuthProvider>
          <PosProvider>
            <GlobalAlertProvider />
            <Toaster />
            <ErrorBoundary>
              <Suspense fallback={<LoadingFallback />}>
                <Routes>
                  <Route path="/login" element={<LoginPage />} />
                  
                  {/* POS PRINCIPAL */}
                  <Route 
                    path="/" 
                    element={
                      <ProtectedRoute>
                        <PosPage />
                      </ProtectedRoute>
                    } 
                  />

                  {/* RUTAS DE TIENDA */}
                  <Route path="/store/:storeId/dashboard" element={<ProtectedRoute><DashboardPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/billing" element={<ProtectedRoute><BillingPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/products" element={<ProtectedRoute><ProductsPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/products/add" element={<ProtectedRoute><AddProductPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/products/departments" element={<ProtectedRoute><DepartmentsPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/products/sub-departments" element={<ProtectedRoute><SubDepartmentsPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/users" element={<ProtectedRoute><UsersPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/users/add" element={<ProtectedRoute><AddUserPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/users/edit/:userId" element={<ProtectedRoute><EditUserPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/settings" element={<ProtectedRoute><SettingsPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/inventory/movements" element={<ProtectedRoute><InventoryMovementsPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/inventory/adjustments" element={<ProtectedRoute><InventoryAdjustmentsPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/suppliers" element={<ProtectedRoute><SuppliersPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/suppliers/add" element={<ProtectedRoute><AddSupplierPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/suppliers/edit/:supplierId" element={<ProtectedRoute><EditSupplierPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/cash-register" element={<ProtectedRoute><CashRegisterPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/authorizations" element={<ProtectedRoute><AuthorizationsPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/pending-orders" element={<ProtectedRoute><PendingOrdersPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/dispatcher" element={<ProtectedRoute><DispatcherPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/control-tower" element={<ProtectedRoute><ControlTowerPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/delivery-route" element={<ProtectedRoute><DeliveryRoutePage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/help" element={<ProtectedRoute><HelpPage /></ProtectedRoute>} />
                  
                  {/* VENDORS MODULE */}
                  <Route path="/store/:storeId/vendors" element={<ProtectedRoute><VendorsPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/vendors/add" element={<ProtectedRoute><AddVendorPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/vendors/dashboard" element={<ProtectedRoute><VendorDashboardPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/vendors/zones" element={<ProtectedRoute><VendorZonesPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/vendors/clients" element={<ProtectedRoute><VendorClientsPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/vendors/collections" element={<ProtectedRoute><VendorCollectionsPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/vendors/inventory" element={<ProtectedRoute><VendorInventoryPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/vendors/quick-sale" element={<ProtectedRoute><VendorQuickSalePage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/vendors/sales" element={<ProtectedRoute><VendorSalesPage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/vendors/assign-route" element={<ProtectedRoute><AssignRoutePage /></ProtectedRoute>} />
                  <Route path="/store/:storeId/vendors/routes" element={<ProtectedRoute><VendorRoutesPage /></ProtectedRoute>} />

                  <Route path="/store/:storeId/reports" element={<ProtectedRoute><ReportsPage /></ProtectedRoute>} />

                  {/* MASTER ADMIN */}
                  <Route path="/master-admin/dashboard" element={<ProtectedRoute><MasterDashboardPage /></ProtectedRoute>} />
                  <Route path="/master-admin/stores" element={<ProtectedRoute><MasterStoresPage /></ProtectedRoute>} />
                  <Route path="/master-admin/stores/add" element={<ProtectedRoute><AddStorePage /></ProtectedRoute>} />
                  <Route path="/master-admin/stores/edit/:storeId" element={<ProtectedRoute><EditStorePage /></ProtectedRoute>} />
                  <Route path="/master-admin/chains" element={<ProtectedRoute><MasterChainsPage /></ProtectedRoute>} />
                  <Route path="/master-admin/chains/add" element={<ProtectedRoute><AddChainPage /></ProtectedRoute>} />
                  <Route path="/master-admin/users" element={<ProtectedRoute><MasterUsersPage /></ProtectedRoute>} />
                  <Route path="/master-admin/users/add" element={<ProtectedRoute><AddUserPage /></ProtectedRoute>} />
                  <Route path="/master-admin/users/edit/:userId" element={<ProtectedRoute><EditUserPage /></ProtectedRoute>} />
                  <Route path="/master-admin/licenses" element={<ProtectedRoute><MasterLicensesPage /></ProtectedRoute>} />
                  <Route path="/master-admin/monitor" element={<ProtectedRoute><MasterMonitorPage /></ProtectedRoute>} />
                  <Route path="/master-admin/config" element={<ProtectedRoute><MasterConfigPage /></ProtectedRoute>} />
                  <Route path="/master-admin/config/zones" element={<ProtectedRoute><MasterZonesPage /></ProtectedRoute>} />
                  <Route path="/master-admin/config/sub-zones" element={<ProtectedRoute><MasterSubZonesPage /></ProtectedRoute>} />
                  <Route path="/master-admin/sync-monitor" element={<ProtectedRoute><MasterSyncMonitorPage /></ProtectedRoute>} />
                  <Route path="/master-admin/help" element={<ProtectedRoute><MasterHelpPage /></ProtectedRoute>} />
                </Routes>
              </Suspense>
            </ErrorBoundary>
          </PosProvider>
        </AuthProvider>
      </BrowserRouter>
    </ThemeProvider>
  );
}

export default App;
