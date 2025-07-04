USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [RH].[fnGetValueMemberFromTable] (@Table varchar(100), @id int)
RETURNS @contacts TABLE (        
        descripcion VARCHAR(max)        
    )
AS
BEGIN
        if @Table = '[RH].[tblCatPuestos]'
            begin 
                INSERT INTO @contacts
                SELECT 
                    Descripcion                                
                from [RH].[tblCatPuestos]
                where IDPuesto=@id            
            end
        else if @Table= '[RH].[tblCatArea]'
            begin
                INSERT INTO @contacts
                SELECT 
                    Descripcion                                
                from [RH].[tblCatArea]
                where IDArea=@id            
            end
        else if @Table='[RH].[tblCatCentroCosto]'
            BEGIN
                INSERT INTO @contacts
                SELECT 
                    Descripcion                                
                from [RH].[tblCatCentroCosto]
                where IDCentroCosto=@id            
            end
        else if @Table='[RH].[tblCatClasificacionesCorporativas]'
            BEGIN
                INSERT INTO @contacts
                SELECT 
                    Descripcion                                
                from [RH].[tblCatClasificacionesCorporativas]
                where IDClasificacionCorporativa=@id            
            end
        else if @Table='[RH].[tblCatDepartamentos]'
            BEGIN
                INSERT INTO @contacts
                SELECT 
                    Descripcion                                
                from [RH].[tblCatDepartamentos]
                where IDDepartamento=@id            
            end
        else if @Table='[RH].[tblCatDivisiones]'
            BEGIN
                INSERT INTO @contacts
                SELECT 
                    Descripcion                                
                from [RH].[tblCatDivisiones]
                where IDDivision=@id            
            end
        else if @Table='[RH].[tblCatTiposPrestaciones]'
            BEGIN
                INSERT INTO @contacts
                SELECT 
                    Descripcion                                
                from [RH].[tblCatTiposPrestaciones]
                where IDTipoPrestacion=@id            
            end
        else if @Table='[RH].[tblCatPuestos]'
            BEGIN
                INSERT INTO @contacts
                SELECT 
                    Descripcion                                
                from [RH].[tblCatPuestos]
                where IDPuesto=@id            
            end
        else if @Table='[RH].[tblCatRazonesSociales]'
            BEGIN
                INSERT INTO @contacts
                SELECT 
                    RazonSocial                                
                from [RH].[tblCatRazonesSociales]
                where IDRazonSocial=@id            
            end
        else if @Table='[RH].[tblCatRegiones]'
            BEGIN
                INSERT INTO @contacts
                SELECT 
                    Descripcion                                
                from [RH].[tblCatRegiones]
                where IDRegion=@id            
            end
        else if @Table='[RH].[tblCatRegPatronal]'
            BEGIN
                INSERT INTO @contacts
                SELECT 
                    RegistroPatronal                                
                from [RH].[tblCatRegPatronal]
                where IDRegPatronal=@id            
            end
        else if @Table='[RH].[tblCatSucursales]'
            BEGIN
                INSERT INTO @contacts
                SELECT 
                    Descripcion                                
                from [RH].[tblCatSucursales]
                where IDSucursal=@id            
            end
        else if @Table='[Nomina].[tblCatTipoNomina]'
            BEGIN
                INSERT INTO @contacts
                SELECT 
                    Descripcion                                
                from [Nomina].[tblCatTipoNomina]
                where IDTipoNomina=@id            
            end
        else if @Table='[RH].[tblCatPosiciones]'
            BEGIN
                INSERT INTO @contacts
                SELECT 
                    concat('Plaza: ',pu.Descripcion,' - Posición: ',s.Codigo)                                
                from  [RH].[tblCatPosiciones] s
                    inner join RH.tblCatPlazas p on p.IDPlaza=s.IDPlaza         
                    inner join rh.tblCatPuestos pu on pu.IDPuesto=p.IDPuesto
                where s.IDPosicion=@id            
            end
		else if @Table='[RH].[tblEmpresa]'
            BEGIN
                INSERT INTO @contacts
                SELECT NombreComercial FROM [RH].[tblEmpresa]
				WHERE IdEmpresa = @id          
            end
        else if @Table='[Seguridad].[tblCatPerfiles]'
            BEGIN
                INSERT INTO @contacts
                SELECT Descripcion FROM [Seguridad].[tblCatPerfiles]
				WHERE IDPerfil = @id          
            end
            

    RETURN;
   
    
END; 
  

--select * From  [RH].[fnGetValueMemberFromTable]('[RH].[tblCatPuestos]',1)
GO
