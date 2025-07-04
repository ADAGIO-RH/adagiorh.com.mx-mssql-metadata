USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staffing].[tblCatMapeoPuestos](
	[IDMapeo] [int] IDENTITY(1,1) NOT NULL,
	[IDSucursal] [int] NULL,
	[IDDepartamento] [int] NULL,
	[IDPuesto] [int] NULL,
 CONSTRAINT [Pk_StaffingtblCatMapeoPuestos_IDMapeo] PRIMARY KEY CLUSTERED 
(
	[IDMapeo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_StaffingtblCatMapeoPuestos_Combination] UNIQUE NONCLUSTERED 
(
	[IDSucursal] ASC,
	[IDDepartamento] ASC,
	[IDPuesto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Staffing].[tblCatMapeoPuestos]  WITH CHECK ADD  CONSTRAINT [FK_StaffingtblCatMapeoPuestos_RHtblCatDepartamentos_IDDepartamento] FOREIGN KEY([IDDepartamento])
REFERENCES [RH].[tblCatDepartamentos] ([IDDepartamento])
GO
ALTER TABLE [Staffing].[tblCatMapeoPuestos] CHECK CONSTRAINT [FK_StaffingtblCatMapeoPuestos_RHtblCatDepartamentos_IDDepartamento]
GO
ALTER TABLE [Staffing].[tblCatMapeoPuestos]  WITH CHECK ADD  CONSTRAINT [FK_StaffingtblCatMapeoPuestos_RHtblCatPuestos_IDPuesto] FOREIGN KEY([IDPuesto])
REFERENCES [RH].[tblCatPuestos] ([IDPuesto])
GO
ALTER TABLE [Staffing].[tblCatMapeoPuestos] CHECK CONSTRAINT [FK_StaffingtblCatMapeoPuestos_RHtblCatPuestos_IDPuesto]
GO
ALTER TABLE [Staffing].[tblCatMapeoPuestos]  WITH CHECK ADD  CONSTRAINT [FK_StaffingtblCatMapeoPuestos_RHtblCatSucursales_IDSucursal] FOREIGN KEY([IDSucursal])
REFERENCES [RH].[tblCatSucursales] ([IDSucursal])
GO
ALTER TABLE [Staffing].[tblCatMapeoPuestos] CHECK CONSTRAINT [FK_StaffingtblCatMapeoPuestos_RHtblCatSucursales_IDSucursal]
GO
