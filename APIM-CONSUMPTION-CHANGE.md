# 🎉 API MANAGEMENT - CAMBIO A SKU CONSUMPTION

## ✅ Cambio Realizado

**SKU modificado:** `Developer_1` → `Consumption_0`

**Fecha:** 22 de diciembre de 2025

---

## 💰 IMPACTO EN COSTOS

### Comparación Mensual

| Concepto | Developer (Antes) | Consumption (Ahora) | Ahorro |
|----------|-------------------|---------------------|--------|
| **Costo base** | $50 USD/mes | $0 USD/mes | $50 USD |
| **Costo por uso** | Incluido | $0.035 USD/10K calls | - |
| **Data transfer** | Incluido | $0.007 USD/GB | - |
| **TOTAL (uso bajo)** | $55-60 USD/mes | $5-15 USD/mes | **~$45 USD/mes** |
| **% Ahorro** | - | - | **~85-90%** |

### Ejemplo de Costos con Consumption

Asumiendo uso típico de laboratorio:

- 50,000 llamadas/mes = $0.175 USD
- 10 GB transferencia = $0.07 USD
- Cosmos DB + Functions + Storage = ~$5 USD
- **Total = ~$5-10 USD/mes**

---

## ⚡ IMPACTO EN DESPLIEGUE

| Fase | Developer | Consumption | Mejora |
|------|-----------|-------------|--------|
| Resource Group | 10 seg | 10 seg | - |
| Virtual Network | 30 seg | 30 seg | - |
| Storage Account | 1 min | 1 min | - |
| Cosmos DB | 5-10 min | 5-10 min | - |
| Function App | 2-3 min | 2-3 min | - |
| **API Management** | **30-45 min** | **5-10 min** | **6x más rápido** |
| **TOTAL** | **45-60 min** | **15-20 min** | **3x más rápido** |

---

## 📋 CARACTERÍSTICAS COMPARADAS

### ✅ Características Mantenidas

- ✅ Gateway de APIs completo
- ✅ Políticas (rate limiting, CORS, transformaciones)
- ✅ Autenticación y autorización
- ✅ Integración con backends (Functions, HTTP)
- ✅ Métricas y Application Insights
- ✅ SLA del 99.95%
- ✅ Gestión de suscripciones y API keys
- ✅ Versionado y revisiones de APIs

### ⚠️ Características NO Disponibles en Consumption

- ❌ **Developer Portal** (UI interactiva para docs)
- ❌ **VNet Integration** (no puede estar en red privada)
- ❌ **Self-hosted Gateway** (despliegue on-premises)
- ❌ **Caché integrado** (requiere caché externa si necesario)
- ⚠️ **Límite de throughput:** 500 MB/sec (suficiente para labs)

---

## 🎯 ¿CUÁNDO USAR CADA SKU?

### ✅ Consumption (Actual) - Ideal Para:

- ✅ Laboratorios y desarrollo
- ✅ Ambientes de prueba
- ✅ Proyectos serverless
- ✅ Cargas de trabajo esporádicas
- ✅ Presupuesto limitado
- ✅ POCs y demos

### 🔄 Developer - Considerar Para:

- Desarrollo que requiere Developer Portal
- Integración con VNets privadas
- Simulación de producción
- Presupuesto no es limitante

### 🏢 Production, Premium - Para Producción:

- Alta disponibilidad (multi-región)
- VNet integration requerida
- Caché distribuida
- Tráfico alto y predecible

---

## 📂 Archivos Modificados

```
✅ main.tf           - SKU cambiado a Consumption_0
✅ README.md         - Documentación actualizada
✅ QUICKSTART.md     - Costos y tiempos actualizados
```

---

## 🚀 Próximos Pasos

### 1. Ejecutar Workflow

El workflow ahora desplegará APIM con SKU Consumption:

**URL:**
```
https://github.com/ImTronick2025/apis-labs-infra/actions/workflows/terraform-azure.yml
```

**Configuración:**
- Terraform action: `apply`
- Environment: `dev`

**Tiempo estimado:** ~15-20 minutos (antes 50-60 min)

### 2. Verificar Recursos

Después del despliegue:

```powershell
# Verificar SKU desplegado
az apim show --name apislabs-apim --resource-group apis-labs-rg --query sku
```

Deberías ver:
```json
{
  "capacity": 0,
  "name": "Consumption"
}
```

### 3. Importar APIs

Las APIs se importan igual que con Developer SKU:

```powershell
cd D:\CLOUDSOLUTIONS\apis-labs-workspace\apis-labs-infra
.\import-apis.ps1 -All
```

---

## 🐛 Troubleshooting

### "El nombre ya está en uso"

Si ya habías desplegado con Developer SKU, Terraform intentará actualizar el recurso existente. Esto puede fallar porque no se puede cambiar SKU en un APIM existente.

**Solución:**

1. Destruir el APIM anterior:
```powershell
az apim delete --name apislabs-apim --resource-group apis-labs-rg --yes
```

2. Ejecutar workflow de nuevo

**O cambiar el nombre:**

En `dev.tfvars`, cambia:
```hcl
prefix = "apislabs2"  # Usar nombre diferente
```

### "Región no soporta Consumption"

Consumption SKU está disponible en la mayoría de regiones, pero verifica:

```powershell
az provider show --namespace Microsoft.ApiManagement --query "resourceTypes[?resourceType=='service'].locations"
```

Si tu región no soporta Consumption, cambia la región en `dev.tfvars`:
```hcl
location = "East US"  # O West Europe, Southeast Asia, etc.
```

---

## 📊 Monitoreo y Costos

### Ver Costos en Tiempo Real

```powershell
# Azure Portal
https://portal.azure.com/#view/Microsoft_Azure_CostManagement

# CLI
az consumption usage list --start-date 2025-12-01 --end-date 2025-12-31
```

### Métricas de APIM

En Azure Portal → API Management → Metrics:
- Total Requests (llamadas)
- Data Transfer (GB)
- Gateway Response Time

---

## ✅ Ventajas del Cambio

1. **💰 Ahorro Masivo:** $45-50/mes menos (~85-90% ahorro)
2. **⚡ Despliegue Rápido:** 3x más rápido (15 min vs 50 min)
3. **☁️ Serverless:** Escala de 0 a ∞ automáticamente
4. **💸 Pay-per-use:** Solo pagas lo que usas
5. **🎯 Perfecto para Labs:** Ideal para aprendizaje y pruebas

---

## 📚 Referencias

- [Azure APIM Consumption Tier](https://docs.microsoft.com/azure/api-management/api-management-features)
- [Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)
- [SKU Comparison](https://docs.microsoft.com/azure/api-management/api-management-features)

---

**Cambio implementado y documentado!** 🎉

**Ahorro estimado anual:** ~$540-600 USD

**Tiempo ahorrado por despliegue:** ~35-40 minutos
