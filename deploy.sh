#!/bin/bash
# Script de despliegue de infraestructura con Terraform

set -e

ENVIRONMENT="${1:-dev}"
ACTION="${2:-plan}"
AUTO_APPROVE="${3:-}"

echo "🚀 Azure APIs Lab - Terraform Deployment"
echo "Environment: $ENVIRONMENT"
echo "Action: $ACTION"
echo ""

# Verificar Terraform instalado
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform no está instalado"
    echo "   Descarga desde: https://www.terraform.io/downloads"
    exit 1
fi

# Verificar Azure CLI instalado
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI no está instalado"
    echo "   Descarga desde: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

# Verificar autenticación en Azure
echo "🔐 Verificando autenticación en Azure..."
if ! az account show &> /dev/null; then
    echo "❌ No estás autenticado en Azure"
    echo "   Ejecuta: az login"
    exit 1
fi
echo "   ✓ Autenticado correctamente"
echo ""

# Archivo de variables
VAR_FILE="${ENVIRONMENT}.tfvars"
if [ ! -f "$VAR_FILE" ]; then
    echo "❌ Archivo de variables no encontrado: $VAR_FILE"
    exit 1
fi

# Inicializar Terraform
if [ ! -d ".terraform" ]; then
    echo "📦 Inicializando Terraform..."
    terraform init
    echo ""
fi

# Ejecutar acción
case "$ACTION" in
    plan)
        echo "📋 Generando plan de ejecución..."
        terraform plan -var-file="$VAR_FILE" -out="terraform.plan"
        ;;
    apply)
        echo "🚀 Aplicando cambios..."
        if [ "$AUTO_APPROVE" == "--auto-approve" ]; then
            terraform apply -var-file="$VAR_FILE" -auto-approve
        else
            terraform apply -var-file="$VAR_FILE"
        fi
        
        echo ""
        echo "✅ Infraestructura desplegada exitosamente!"
        echo ""
        echo "📊 Outputs importantes:"
        terraform output
        ;;
    destroy)
        echo "⚠️  ADVERTENCIA: Esto destruirá TODOS los recursos!"
        echo "   Environment: $ENVIRONMENT"
        echo ""
        
        if [ "$AUTO_APPROVE" != "--auto-approve" ]; then
            read -p "¿Estás seguro? Escribe 'yes' para continuar: " confirm
            if [ "$confirm" != "yes" ]; then
                echo "❌ Operación cancelada"
                exit 0
            fi
        fi
        
        echo "💥 Destruyendo infraestructura..."
        terraform destroy -var-file="$VAR_FILE" -auto-approve
        ;;
    output)
        echo "📊 Outputs de Terraform:"
        terraform output
        ;;
    *)
        echo "❌ Acción no válida: $ACTION"
        echo "   Acciones válidas: plan, apply, destroy, output"
        exit 1
        ;;
esac

echo ""
echo "✅ Proceso completado"
