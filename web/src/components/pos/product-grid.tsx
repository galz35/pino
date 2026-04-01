import { useState, useEffect } from 'react';
import { Input } from '@/components/ui/input';
import { Search, Package } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { usePos } from '@/contexts/pos-context';
import { useParams } from 'react-router-dom';
import apiClient from '@/services/api-client';
import { Product } from '@/types';

export function ProductGrid() {
    const { addToCart } = usePos();
    const params = useParams();
    const storeId = params.storeId as string;
    const [searchTerm, setSearchTerm] = useState('');
    const [products, setProducts] = useState<Product[]>([]);
    const [loading, setLoading] = useState(true);

    // Initial load & Search logic
    useEffect(() => {
        const fetchProducts = async () => {
            if (!storeId) return;

            setLoading(true);
            try {
                const response = await apiClient.get('/products', {
                    params: {
                        storeId,
                        search: searchTerm,
                        limit: 20
                    }
                });
                setProducts(response.data);
            } catch (err) {
                console.error("Error loading products", err);
            } finally {
                setLoading(false);
            }
        };

        const timeoutId = setTimeout(fetchProducts, searchTerm ? 500 : 0);
        return () => clearTimeout(timeoutId);
    }, [storeId, searchTerm]);

    return (
        <div className="h-full flex flex-col bg-white">
            {/* Search Header */}
            <div className="p-4 border-b flex gap-2 items-center bg-white sticky top-0 z-10">
                <div className="relative flex-1">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
                    <Input
                        placeholder="Buscar productos..."
                        className="pl-10 h-12 text-lg bg-gray-50 border-gray-200"
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        autoFocus
                    />
                </div>
            </div>

            {/* Grid Content */}
            <div className="flex-1 overflow-y-auto p-4 bg-gray-50/50">
                {loading ? (
                    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                        {[1, 2, 3, 4, 5, 6, 7, 8].map(i => <Skeleton key={i} className="h-48 rounded-lg" />)}
                    </div>
                ) : products.length === 0 ? (
                    <div className="flex flex-col items-center justify-center h-full text-gray-400">
                        <Package className="h-16 w-16 mb-4 opacity-20" />
                        <p>No se encontraron productos</p>
                    </div>
                ) : (
                    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 pb-20">
                        {products.map((product) => (
                            <Card
                                key={product.id}
                                className="cursor-pointer hover:shadow-md hover:border-primary/50 transition-all active:scale-95 flex flex-col"
                                onClick={() => addToCart(product)}
                            >
                                <CardContent className="p-4 flex flex-col items-center text-center h-full justify-between">
                                    <div className="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center mb-3 text-gray-500">
                                        <Package className="h-6 w-6" />
                                    </div>
                                    <div className="space-y-1">
                                        <h3 className="font-semibold text-sm line-clamp-2 leading-tight min-h-[2.5em]">{product.description}</h3>
                                        <p className="text-xs text-muted-foreground">{product.barcode || '...'}</p>
                                    </div>
                                    <div className="mt-3 font-bold text-lg text-primary">
                                        C$ {product.salePrice.toFixed(2)}
                                    </div>
                                </CardContent>
                            </Card>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
}
