import { FloatingActionButton } from "@/components/floating-action-button";
import { Card, CardContent } from "@/components/ui/card";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { Badge } from "@/components/ui/badge";
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
    AlertDialogTrigger,
} from '@/components/ui/alert-dialog';
import { Package, FileText, Shapes, Library, ChevronRight, Wrench } from "lucide-react";
import { useParams, useNavigate } from "react-router-dom";
import { useEffect, useState, useMemo } from 'react';
import apiClient from '@/services/api-client';
import { logError } from '@/lib/error-logger';
import { Link } from 'react-router-dom';
import { cn } from '@/lib/utils';
import { ImportProductsDialog } from '@/components/products/import-products-dialog';

interface Department {
    id: string;
    name: string;
}

interface SubDepartment {
    id: string;
    name: string;
    departmentId: string;
}

interface Product {
    id: string;
    barcode?: string;
    description: string;
    salePrice: number;
    currentStock: number;
    unitsPerBulk?: number;
    stockBulks?: number;
    stockUnits?: number;
    minStock: number;
    usesInventory: boolean;
    department?: string;
    subDepartment?: string;
}

function getStockBadgeVariant(currentStock: number, minStock: number) {
    if (currentStock === 0) return 'text-white bg-destructive hover:bg-destructive';
    if (currentStock <= minStock) return 'text-white bg-orange-500 hover:bg-orange-500';
    return 'text-white bg-green-600 hover:bg-green-600';
}

export default function ProductsPage() {
    const params = useParams();
    const storeId = params.storeId as string;
    const navigate = useNavigate();

    const [products, setProducts] = useState<Product[]>([]);
    const [departments, setDepartments] = useState<Department[]>([]);
    const [subDepartments, setSubDepartments] = useState<SubDepartment[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    const [selectedDepartment, setSelectedDepartment] = useState<Department | null>(null);
    const [selectedSubDepartment, setSelectedSubDepartment] = useState<SubDepartment | null>(null);
    const [reorganizationMode, setReorganizationMode] = useState(false);
    const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);

    useEffect(() => {
        if (!storeId) return;

        let isMounted = true;
        setLoading(true);

        const fetchData = async () => {
            try {
                const [prodsRes, deptsRes] = await Promise.all([
                    apiClient.get('/products', { params: { storeId } }),
                    apiClient.get('/departments', { params: { storeId } }),
                    // Sub-departments are currently not actively migrated to a separate table
                    // We'll leave subDepartments as an empty array for now
                ]);

                if (isMounted) {
                    setProducts(prodsRes.data as Product[]);
                    setDepartments(deptsRes.data.map((d: any) => ({ ...d, name: d.name || d.nombre })));
                    setSubDepartments([]); // Simulated empty for now
                    setLoading(false);
                }
            } catch (err: any) {
                if (isMounted) {
                    logError(err, { location: 'products-page-fetch-api' });
                    setError('No se pudieron cargar los datos.');
                    setLoading(false);
                }
            }
        };

        fetchData();

        return () => {
            isMounted = false;
        };
    }, [storeId]);

    const unorganizedProducts = useMemo(() => {
        return products.filter(p => !p.department || p.department === '');
    }, [products]);

    const filteredProducts = useMemo(() => {
        if (selectedSubDepartment) {
            if (selectedSubDepartment.id === 'none') {
                return products.filter(p => p.department === selectedDepartment?.name && !p.subDepartment);
            }
            return products.filter(p => p.department === selectedDepartment?.name && p.subDepartment === selectedSubDepartment.name);
        }
        if (selectedDepartment) {
            return products.filter(p => p.department === selectedDepartment.name && !p.subDepartment);
        }
        return [];
    }, [products, selectedDepartment, selectedSubDepartment]);

    const filteredSubDepartments = useMemo(() => {
        if (!selectedDepartment) return [];
        return subDepartments.filter(sd => sd.departmentId === selectedDepartment.id);
    }, [subDepartments, selectedDepartment]);

    const handleEdit = () => {
        if (selectedProduct) {
            navigate(`/store/${storeId}/products/edit/${selectedProduct.id}`);
        }
    };

    const resetSelection = () => {
        setSelectedDepartment(null);
        setSelectedSubDepartment(null);
        setReorganizationMode(false);
    }

    const productCountsBySubDept = useMemo(() => {
        const counts = new Map<string, number>();
        products.forEach(product => {
            if (product.department && product.subDepartment) {
                const key = `${product.department}-${product.subDepartment}`;
                counts.set(key, (counts.get(key) || 0) + 1);
            }
        });
        return counts;
    }, [products]);

    const productCountsByDept = useMemo(() => {
        const counts = new Map<string, number>();
        products.forEach(product => {
            if (product.department && !product.subDepartment) {
                counts.set(product.department, (counts.get(product.department) || 0) + 1);
            }
        });
        return counts;
    }, [products]);

    const renderBreadcrumb = () => (
        <div className="flex items-center text-sm text-muted-foreground mb-4">
            <button onClick={resetSelection} className="hover:underline">Inicio</button>
            {reorganizationMode && (
                <>
                    <ChevronRight className="h-4 w-4 mx-1" />
                    <span className="font-semibold text-foreground">Reorganizar</span>
                </>
            )}
            {selectedDepartment && !reorganizationMode && (
                <>
                    <ChevronRight className="h-4 w-4 mx-1" />
                    <button onClick={() => setSelectedSubDepartment(null)} className="hover:underline">{selectedDepartment.name}</button>
                </>
            )}
            {selectedSubDepartment && !reorganizationMode && (
                <>
                    <ChevronRight className="h-4 w-4 mx-1" />
                    <span className="font-semibold text-foreground">{selectedSubDepartment.name}</span>
                </>
            )}
        </div>
    );

    const renderContent = () => {
        if (loading) {
            return (
                <div className="space-y-3">
                    {Array.from({ length: 5 }).map((_, i) => <Skeleton key={i} className="h-20 w-full" />)}
                </div>
            )
        }

        if (error) {
            return (
                <Alert variant="destructive">
                    <Package className="h-4 w-4" />
                    <AlertTitle>Error</AlertTitle>
                    <AlertDescription>{error}</AlertDescription>
                </Alert>
            )
        }

        const productListContent = (productsToList: Product[]) => {
            if (productsToList.length === 0) {
                return <Alert><Package className="h-4 w-4" /><AlertTitle>No hay productos</AlertTitle><AlertDescription>No se encontraron productos en esta categoría.</AlertDescription></Alert>
            }
            return (
                <div className="space-y-3">
                    <AlertDialog>
                        {productsToList.map((product) => (
                            <AlertDialogTrigger asChild key={product.id} onClick={() => setSelectedProduct(product)}>
                                <Card className="hover:bg-muted/50 transition-colors cursor-pointer">
                                    <CardContent className="p-4 grid grid-cols-2 sm:grid-cols-4 md:grid-cols-5 items-center gap-4">
                                        <div className="col-span-2">
                                            <p className="font-semibold">{product.description}</p>
                                            {reorganizationMode && <p className="text-xs text-destructive">Departamento: {product.department || 'Ninguno'}</p>}
                                        </div>
                                        <div className="text-right sm:text-left">
                                            <p className="text-xs text-muted-foreground">Precio</p>
                                            <p className="font-medium">C$ {product.salePrice.toFixed(2)}</p>
                                        </div>
                                            <div className="text-right sm:text-left">
                                                <p className="text-xs text-muted-foreground">Stock</p>
                                                {product.usesInventory ? (
                                                    <div className="flex flex-col items-end sm:items-start">
                                                        <Badge variant="default" className={cn("text-base", getStockBadgeVariant(product.currentStock, product.minStock))}>
                                                            {product.currentStock} T
                                                        </Badge>
                                                        {(product.unitsPerBulk || 1) > 1 && (
                                                            <p className="text-xs text-muted-foreground mt-1">
                                                                {product.stockBulks || 0} Bulto{(product.stockBulks !== 1) ? 's' : ''}, {product.stockUnits || 0} U
                                                            </p>
                                                        )}
                                                    </div>
                                                ) : (
                                                    <Badge variant="secondary">N/A</Badge>
                                                )}
                                            </div>
                                    </CardContent>
                                </Card>
                            </AlertDialogTrigger>
                        ))}
                        <AlertDialogContent>
                            <AlertDialogHeader>
                                <AlertDialogTitle>¿Qué deseas hacer con &quot;{selectedProduct?.description}&quot;?</AlertDialogTitle>
                                <AlertDialogDescription>
                                    Selecciona una opción para continuar.
                                </AlertDialogDescription>
                            </AlertDialogHeader>
                            <AlertDialogFooter>
                                <AlertDialogCancel>Cancelar</AlertDialogCancel>
                                <AlertDialogAction onClick={handleEdit}>
                                    Editar
                                </AlertDialogAction>
                            </AlertDialogFooter>
                        </AlertDialogContent>
                    </AlertDialog>
                </div>
            )
        }

        // View Reorganization
        if (reorganizationMode) {
            return productListContent(unorganizedProducts);
        }

        // View Products for a department (no sub-department) or a sub-department
        if (selectedSubDepartment || (selectedDepartment && filteredSubDepartments.length === 0)) {
            return productListContent(filteredProducts);
        }

        // View Sub-Departments for a department
        if (selectedDepartment) {
            const productsInDeptOnly = productCountsByDept.get(selectedDepartment.name) || 0;
            return (
                <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
                    {filteredSubDepartments.map(subDept => {
                        const count = productCountsBySubDept.get(`${selectedDepartment.name}-${subDept.name}`) || 0;
                        return (
                            <Card key={subDept.id} className="hover:bg-muted/50 transition-colors cursor-pointer" onClick={() => setSelectedSubDepartment(subDept)}>
                                <CardContent className="p-4 flex items-center justify-between">
                                    <div className="flex items-center gap-3">
                                        <Library className="h-5 w-5 text-muted-foreground" />
                                        <p className="font-semibold">{subDept.name}</p>
                                        <Badge variant="secondary">{count}</Badge>
                                    </div>
                                    <ChevronRight className="h-5 w-5 text-muted-foreground" />
                                </CardContent>
                            </Card>
                        )
                    })}
                    {productsInDeptOnly > 0 && (
                        <Card className="hover:bg-muted/50 transition-colors cursor-pointer border-dashed" onClick={() => setSelectedSubDepartment({ id: 'none', name: 'Sin Sub-departamento', departmentId: selectedDepartment.id })}>
                            <CardContent className="p-4 flex items-center justify-between">
                                <div className="flex items-center gap-3">
                                    <Package className="h-5 w-5 text-muted-foreground" />
                                    <p className="font-semibold">Sin Sub-departamento</p>
                                    <Badge variant="secondary">{productsInDeptOnly}</Badge>
                                </div>
                                <ChevronRight className="h-5 w-5 text-muted-foreground" />
                            </CardContent>
                        </Card>
                    )}
                </div>
            )
        }

        // View Departments
        if (departments.length === 0) {
            return <Alert><Shapes className="h-4 w-4" /><AlertTitle>No hay departamentos</AlertTitle><AlertDescription>No has creado ningún departamento. Empieza por crear uno para organizar tus productos.</AlertDescription></Alert>
        }

        return (
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
                {departments.map(dept => (
                    <Card key={dept.id} className="hover:bg-muted/50 transition-colors cursor-pointer" onClick={() => setSelectedDepartment(dept)}>
                        <CardContent className="p-4 flex items-center justify-between">
                            <div className="flex items-center gap-3">
                                <Shapes className="h-5 w-5 text-muted-foreground" />
                                <p className="font-semibold">{dept.name}</p>
                            </div>
                            <ChevronRight className="h-5 w-5 text-muted-foreground" />
                        </CardContent>
                    </Card>
                ))}
            </div>
        )
    }

    return (
        <div>
            <div className="mb-6">
                <h1 className="text-2xl font-bold tracking-tight">Gestión de Productos</h1>
                <p className="text-muted-foreground">
                    Administra el inventario, precios y categorías de tus productos.
                </p>
            </div>
            <div className="flex flex-wrap gap-2 mb-6">
                <Button variant="outline" asChild>
                    <Link to={`/store/${storeId}/products/departments`}>
                        <Shapes className="mr-2 h-4 w-4" />
                        Depart.
                    </Link>
                </Button>
                <Button variant="outline" asChild>
                    <Link to={`/store/${storeId}/products/sub-departments`}>
                        <Library className="mr-2 h-4 w-4" />
                        Sub-Depart.
                    </Link>
                </Button>
                <Button variant="outline" onClick={() => { setReorganizationMode(true); setSelectedDepartment(null); setSelectedSubDepartment(null); }} className="relative">
                    <Wrench className="mr-2 h-4 w-4" />
                    Reorganizar
                    {unorganizedProducts.length > 0 && (
                        <Badge variant="destructive" className="absolute -top-2 -right-2 px-2">
                            {unorganizedProducts.length}
                        </Badge>
                    )}
                </Button>
                <ImportProductsDialog storeId={storeId} departments={departments} />
                <Button variant="outline" disabled>
                    <FileText className="mr-2 h-4 w-4" />
                    Factura
                </Button>
            </div>

            {renderBreadcrumb()}
            {renderContent()}

            <FloatingActionButton href={`/store/${storeId}/products/add`} />
        </div>
    );
}
