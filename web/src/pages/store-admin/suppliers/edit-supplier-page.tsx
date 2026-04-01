import { useState, useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { 
  ArrowLeft, 
  Save, 
  Building2, 
  Phone, 
  Mail, 
  MapPin, 
  User, 
  Loader2,
  Edit3
} from 'lucide-react';
import { 
  Card, 
  CardContent, 
} from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import apiClient from '@/services/api-client';
import { toast } from '@/lib/swalert';

export default function EditSupplierPage() {
  const { storeId, supplierId } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  
  const [formData, setFormData] = useState({
    name: '',
    contactName: '',
    phone: '',
    email: '',
    address: ''
  });

  useEffect(() => {
    fetchSupplier();
  }, [supplierId]);

  const fetchSupplier = async () => {
    if (!supplierId) return;
    try {
      const response = await apiClient.get(`/suppliers/${supplierId}`);
      const data = response.data;
      setFormData({
        name: data.name,
        contactName: data.contactName,
        phone: data.phone,
        email: data.email || '',
        address: data.address
      });
    } catch (error) {
      console.error('Error fetching supplier:', error);
      toast.error('Error', 'No se pudo cargar la información del proveedor.');
      navigate(`/store-admin/${storeId}/suppliers`);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      await apiClient.patch(`/suppliers/${supplierId}`, formData);
      toast.success('Actualizado', 'Los datos del proveedor han sido actualizados.');
      navigate(`/store-admin/${storeId}/suppliers`);
    } catch (error: any) {
      const msg = error.response?.data?.message || 'Error al actualizar el proveedor.';
      toast.error('Error', msg);
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="h-screen flex items-center justify-center">
        <div className="animate-spin h-12 w-12 border-4 border-primary border-t-transparent rounded-full"></div>
      </div>
    );
  }

  return (
    <div className="p-6 max-w-4xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <Button variant="ghost" className="rounded-xl font-bold h-12 text-slate-400 hover:text-primary transition-colors" asChild>
          <Link to={`/store-admin/${storeId}/suppliers`}>
            <ArrowLeft className="mr-2 h-5 w-5" />
            CANCELAR EDICIÓN
          </Link>
        </Button>
      </div>

      <div className="flex flex-col gap-1 items-center text-center py-4">
          <div className="w-16 h-16 rounded-[24px] bg-amber-50 flex items-center justify-center text-amber-500 mb-4 shadow-[5px_5px_15px_#ccced1,-5px_-5px_15px_#ffffff]">
             <Edit3 className="h-8 w-8" />
          </div>
          <h1 className="text-3xl font-black tracking-tight text-slate-800 uppercase">Modificar Proveedor</h1>
          <p className="text-slate-500 font-medium font-mono uppercase tracking-[0.2em]">{formData.name}</p>
      </div>

      <form onSubmit={handleSubmit}>
        <Card className="border-none shadow-[20px_20px_60px_#ccced1,-20px_-20px_60px_#ffffff] bg-[#f0f2f5] rounded-[40px] p-4 md:p-8">
          <CardContent className="space-y-8 pt-6">
            <div className="grid md:grid-cols-2 gap-8">
              {/* Información Básica */}
              <div className="space-y-6">
                <div className="space-y-2">
                  <Label className="text-xs font-bold text-slate-500 uppercase tracking-widest pl-2 flex items-center gap-2">
                    <Building2 className="h-3 w-3" />
                    Nombre de la Empresa
                  </Label>
                  <Input 
                    required
                    className="h-14 rounded-2xl bg-[#f0f2f5] border-none shadow-[inset_4px_4px_8px_#ccced1,inset_-4px_-4px_8px_#ffffff] focus-visible:ring-2 focus-visible:ring-primary/20 transition-all font-bold text-slate-700"
                    value={formData.name}
                    onChange={(e) => setFormData({...formData, name: e.target.value})}
                  />
                </div>

                <div className="space-y-2">
                  <Label className="text-xs font-bold text-slate-500 uppercase tracking-widest pl-2 flex items-center gap-2">
                    <User className="h-3 w-3" />
                    Persona de Contacto
                  </Label>
                  <Input 
                    required
                    className="h-14 rounded-2xl bg-[#f0f2f5] border-none shadow-[inset_4px_4px_8px_#ccced1,inset_-4px_-4px_8px_#ffffff] focus-visible:ring-2 focus-visible:ring-primary/20 transition-all font-bold text-slate-700"
                    value={formData.contactName}
                    onChange={(e) => setFormData({...formData, contactName: e.target.value})}
                  />
                </div>
              </div>

              {/* Datos de Comunicación */}
              <div className="space-y-6">
                <div className="space-y-2">
                  <Label className="text-xs font-bold text-slate-500 uppercase tracking-widest pl-2 flex items-center gap-2">
                    <Phone className="h-3 w-3" />
                    Teléfono Corporativo
                  </Label>
                  <Input 
                    required
                    type="tel"
                    className="h-14 rounded-2xl bg-[#f0f2f5] border-none shadow-[inset_4px_4px_8px_#ccced1,inset_-4px_-4px_8px_#ffffff] focus-visible:ring-2 focus-visible:ring-primary/20 transition-all font-bold tracking-widest text-slate-700"
                    value={formData.phone}
                    onChange={(e) => setFormData({...formData, phone: e.target.value})}
                  />
                </div>

                <div className="space-y-2">
                  <Label className="text-xs font-bold text-slate-500 uppercase tracking-widest pl-2 flex items-center gap-2">
                    <Mail className="h-3 w-3" />
                    Correo Electrónico
                  </Label>
                  <Input 
                    type="email"
                    className="h-14 rounded-2xl bg-[#f0f2f5] border-none shadow-[inset_4px_4px_8px_#ccced1,inset_-4px_-4px_8px_#ffffff] focus-visible:ring-2 focus-visible:ring-primary/20 transition-all font-bold text-slate-700"
                    value={formData.email}
                    onChange={(e) => setFormData({...formData, email: e.target.value})}
                  />
                </div>
              </div>
            </div>

            {/* Dirección Completa */}
            <div className="space-y-4 pt-4 border-t border-slate-200/50">
               <div className="space-y-2">
                  <Label className="text-xs font-bold text-slate-500 uppercase tracking-widest pl-2 flex items-center gap-2">
                    <MapPin className="h-3 w-3" />
                    Ubicación y Domicilio Fiscal
                  </Label>
                  <Textarea 
                    required
                    className="min-h-[120px] rounded-[30px] p-6 bg-[#f0f2f5] border-none shadow-[inset_8px_8px_16px_#ccced1,inset_-8px_-8px_16px_#ffffff] focus-visible:ring-2 focus-visible:ring-primary/20 transition-all font-medium text-slate-700 leading-relaxed"
                    value={formData.address}
                    onChange={(e) => setFormData({...formData, address: e.target.value})}
                  />
               </div>
            </div>

            <div className="flex justify-center pt-8">
                <Button 
                    type="submit" 
                    className="h-16 px-16 rounded-[24px] text-lg font-black tracking-widest shadow-[10px_10px_20px_#ccced1,-10px_-10px_20px_#ffffff] active:shadow-[inset_5px_5px_10px_#ccced1,inset_-5px_-5px_10px_#ffffff] transition-all bg-amber-500 hover:bg-amber-600 uppercase"
                    disabled={saving}
                >
                    {saving ? (
                        <>
                            <Loader2 className="mr-3 h-6 w-6 animate-spin" />
                            ACTUALIZANDO...
                        </>
                    ) : (
                        <>
                            <Save className="mr-3 h-6 w-6" />
                            GUARDAR CAMBIOS
                        </>
                    )}
                </Button>
            </div>
          </CardContent>
        </Card>
      </form>
    </div>
  );
}
