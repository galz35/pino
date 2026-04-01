
import { LeftPanel } from './left-panel';
import { RightPanel } from './right-panel';



export function PosLayout() {
    return (
        <div className="h-[calc(100vh-4rem)] bg-gray-100 flex overflow-hidden">
            {/* Panel Izquierdo (Ticket y Acciones) */}
            <LeftPanel className="w-[30%] border-r border-gray-200" />

            {/* Panel Derecho (Catálogo/Grid) */}
            <RightPanel className="w-[70%]" />
        </div>
    );
}
