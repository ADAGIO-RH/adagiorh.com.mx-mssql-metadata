USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2022-01-27
-- Description:	
-- =============================================

CREATE PROCEDURE [RH].[spIUOrganigramasPosiciones]
    @IDOrganigramaPosicion int ,  
    @Data varchar(max) ,  
    @Nombre varchar(100) ,  
    @IDUsuario int
AS
BEGIN
    
    IF(@IDOrganigramaPosicion = 0)  
        BEGIN  	
                
            INSERT INTO [RH].[tblOrganigramasPosiciones] (Data,Nombre)
            values (@Data,@Nombre) 

            set @IDOrganigramaPosicion=@@IDENTITY         		        
        END
    ELSE  
    BEGIN                	
        UPDATE [RH].[tblOrganigramasPosiciones] set 
            Nombre=@Nombre,
            Data=@Data                   
        WHERE IDOrganigramaPosicion=@IDOrganigramaPosicion                 
    END                        
    select * From [RH].[tblOrganigramasPosiciones] where IDOrganigramaPosicion=@IDOrganigramaPosicion
END
GO
