USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatOrganigramas]
(
	@IDOrganigrama int = 0	
)
AS
BEGIN

    IF @IDOrganigrama=0 
    BEGIN
        SELECT  
            [IDOrganigrama],
            [Filtro],
            [IDReferencia] ,
            '' [DescripcionReferencia]
        FROM rh.tblCatOrganigramas
        WHERE IDOrganigrama =@IDOrganigrama OR ISNULL(@IDOrganigrama,0)=0

            
    END
    ELSE 
    BEGIN 
        SELECT  
            [IDOrganigrama],
            [Filtro],
            [IDReferencia] ,
                CASE 
                    when Filtro = 'RazonesSociales' then isnull((select  empresa.NombreComercial from RH.tblEmpresa empresa where empresa.IdEmpresa = IDReferencia),'')                     
                    when Filtro = 'Clientes' then isnull((select cliente.NombreComercial from RH.tblCatClientes cliente where cliente.IDCliente = IDReferencia),'') 
                    when Filtro = 'Sucursales' then isnull((select suc.Descripcion from RH.tblCatSucursales suc where suc.IDSucursal = IDReferencia),'') 
            END [DescripcionReferencia]
        FROM rh.tblCatOrganigramas
        WHERE IDOrganigrama =@IDOrganigrama OR ISNULL(@IDOrganigrama,0)=0
    END

    
END
GO
