const fs = require('fs');
const path = require('path');

const modules = [
  'users',
  'stores',
  'chains',
  'products',
  'departments',
  'sales',
  'inventory',
  'cash-shifts',
  'clients',
  'orders',
  'suppliers',
  'notifications',
];

modules.forEach((mod) => {
  const dir = path.join(__dirname, '..', 'src', 'modules', mod);
  fs.mkdirSync(dir, { recursive: true });

  const camelMod = mod.split('-').map(p => p[0].toUpperCase() + p.slice(1)).join('');
  const className = `${camelMod}Module`;

  const moduleContent = `import { Module } from '@nestjs/common';
import { ${camelMod}Controller } from './${mod}.controller';
import { ${camelMod}Service } from './${mod}.service';

@Module({
  controllers: [${camelMod}Controller],
  providers: [${camelMod}Service],
  exports: [${camelMod}Service],
})
export class ${className} {}
`;

  const controllerContent = `import { Controller } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ${camelMod}Service } from './${mod}.service';

@ApiTags('${camelMod}')
@Controller('${mod}')
export class ${camelMod}Controller {
  constructor(private readonly service: ${camelMod}Service) {}
}
`;

  const serviceContent = `import { Injectable } from '@nestjs/common';

@Injectable()
export class ${camelMod}Service {
}
`;

  fs.writeFileSync(path.join(dir, `${mod}.module.ts`), moduleContent);
  fs.writeFileSync(path.join(dir, `${mod}.controller.ts`), controllerContent);
  fs.writeFileSync(path.join(dir, `${mod}.service.ts`), serviceContent);
});

console.log('✅ Estructura base de módulos creada (Gemini 🟢)');
