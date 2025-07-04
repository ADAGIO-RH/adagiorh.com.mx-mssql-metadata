USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Quitar el certificado de la empresa
** Autor			: Jcastillo
** Email			: jcastillo@adagio.com.mx	
** FechaCreacion	: 2025-02-02
** Paremetros		:              
** Versión 1.2 

** DataTypes Relacionados: 
** Tablas			: Facturacion.ConfiguracionEmpresa

  VARIABLES A REEMPLAZAR (SIN LOS ESPACIOS)

  {{ DescripcionConcepto }}
  {{ CodigoConcepto }}

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE procedure [Facturacion].[spEliminarCertificados]  
(  
    @IDConfigEmpresa int,  
    @IDUsuario int  
)  
AS  
BEGIN  
    update Facturacion.tblCatConfigEmpresa  
    set TieneCertificado = 0  
    WHERE IDConfigEmpresa = @IDConfigEmpresa  
END
GO
